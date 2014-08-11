#!/usr/bin/env perl

use strict;

use constant LAUNCH_FILE => 'launch.ini';

use File::Basename;
use File::Spec;
use Data::Dumper;

sub find_launch_files($) {
  my $dir = shift || die("invalid directory");
  local *DIR;
  my @launch_files = ();
  my @directories = ();
  push @directories, $dir;
  while (@directories) {
    $dir = shift @directories;
    opendir(*DIR, "$dir") or die("$dir: $!\n");
    while (my $d = readdir(*DIR)) {
      if ($d ne File::Spec->updir() && $d ne File::Spec->curdir()) {
        my $fn = File::Spec->catfile($dir, $d);
        if (-d "$fn") {
          push @directories, "$fn";
        }
        elsif ($d eq LAUNCH_FILE) {
          push @launch_files, "$fn";
        }
      }
    }
    closedir(*DIR);
  }
  return sort @launch_files;
}

sub parse_launch_file($\%) {
  my $filename = shift || die('invalid filename');
  local *FILE;
  my %content = ();
  my $section = '';
  open(*FILE, "< $filename") or die("$filename: $!\n");
  my @sections = ();
  while (my $line = <FILE>) {
    $line =~ s/^\s+//s;
    $line =~ s/\s+$//s;
    if ($line =~ /^\[([a-zA-Z0-9_]+?)\]$/) {
      $section = $1;
      push @sections, $section;
    }
    elsif ($line =~ /^([a-zA-Z0-9_]+)\s*\=\s*(.*)$/) {
      if ($section) {
        $content{$section}{lc($1)} = $2;
      }
      else {
        $content{'*'}{lc($1)} = $2;
      }
    }
  }
  close(*FILE);
  $content{'*'}{'sections'} = \@sections;
  if ($content{'*'}{'name'}) {
    $_[0]->{$filename} = \%content;
  }
  else {
    die("Invalid launch file: $filename\n");
  }
}

sub parse_parameters($$) {
  my $help = shift || '';
  my @parameters = ();
  if ($_[0]) {
    my @params = split(//, $_[0]);
    foreach my $p (@params) {
      $p = lc($p);
      if ($p eq 'i') {
        if (!@ARGV) {
          die("An integer value is missed on the command line.\n$help\n");
        }
        my $value = int(shift @ARGV);
	push @parameters, $value;
      }
      elsif ($p eq 's') {
        if (!@ARGV) {
          die("A value is missed on the command line.\n$help\n");
        }
        my $value = shift @ARGV;
	push @parameters, "\"$value\"";
      }
      else {
        die("invalid parameter type character: $p\n");
      }
    }
  }
  return @parameters;
}

my @launch_files = find_launch_files(dirname($0));

my %launch_data = ();
foreach my $launch_file (@launch_files) {
  parse_launch_file( $launch_file, %launch_data);
}

my $demonumber = shift @ARGV;

if ($demonumber) {
  my $nb = int($demonumber) - 1;
  if ($launch_files[$nb] && $launch_data{$launch_files[$nb]}) {
    my $demo = $launch_data{$launch_files[$nb]};
    print "Launching demo: " . $demo->{'*'}{'name'} . "...\n";
    my @wait_children = ();
    my @killable_children = ();
    my $wait_delay = undef;
    foreach my $agent_key (@{$demo->{'*'}{'sections'}}) {
      my $agent_name = $demo->{$agent_key}{'name'};
      if ($agent_name) {
        my $agent_autokill = lc($demo->{$agent_key}{'autokill'}||'') eq 'true';
        my @agent_parameters = parse_parameters($demo->{$agent_key}{'help'}, $demo->{$agent_key}{'parameters'});
        if ($wait_delay) {
          print "> waiting $wait_delay second(s)\n";
          sleep($wait_delay);
          $wait_delay = undef;
        }
        print "> launching $agent_name\n";
        my $params = join(' ', $agent_name, @agent_parameters);
        my @cmd_line = ( 'mvn',
                         '-q',
                         'exec:java',
                         '-Dexec.mainClass=io.janusproject.Boot',
                         '-Dexec.args='.$params);
        my $pid = fork();
        if ($pid) {
          if ($agent_autokill) {
            push @killable_children, $pid;
          }
          else {
            push @wait_children, $pid;
          }
          if ($demo->{$agent_key}{'wait'}) {
            $wait_delay = int($demo->{$agent_key}{'wait'});
          }
	}
        else {
          exec @cmd_line;
          die("exec failed!");
        }
      }
    }
    print "> waiting for demo termination...\n";
    foreach my $pid (@wait_children) {
      waitpid($pid, 0);
    }
    foreach my $pid (@killable_children) {
      kill -9, $pid or print STDERR "Unable to kill child process: $!\n";
    }
    print "> demo is terminated.\n";
    exit(0);
  }
  else {
    print STDERR "Invalid demo number: $demonumber ($nb)\n";
    print STDERR Dumper($launch_files[$nb]);
    print STDERR Dumper(\%launch_data);
  }
}

my $i = 1;
print "usage: " . basename($0) . " <number>\n\n";
print "<number> is one of:\n";
foreach my $file (@launch_files) {
  if ($launch_data{$file}) {
    my $isvalid = lc($launch_data{$file}{'*'}{'valid'} || '') ne 'false';
    print "$i - " . $launch_data{$file}{'*'}{'name'};
    if (!$isvalid) {
      print " (BUGGED)";
    }
    print "\n";
    $i++;
  }
}

exit(255);

