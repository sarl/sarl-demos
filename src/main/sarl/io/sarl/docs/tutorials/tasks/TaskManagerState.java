package io.sarl.docs.tutorials.tasks;

/** State of the task manager.
 * 
 * @author $Author: galland$
 * @version $Name$ $Revision$ $Date$
 * @mavengroupid $GroupId$
 * @mavenartifactid $ArtifactId$
 */
public enum TaskManagerState {
	/** No execution request. */
	NO_REQUEST,
	/** Waiting for end of execution with a successful execution. */
	WAITING_EXECUTION_TERMINATION_WITH_SUCCESS,
	/** Waiting for end of execution with a errorneous execution. */
	WAITING_EXECUTION_TERMINATION_WITH_ERROR,
	/** Execution is terminated on success. */
	SUCCESS,
	/** Execution is terminated on error. */
	ERROR
}
