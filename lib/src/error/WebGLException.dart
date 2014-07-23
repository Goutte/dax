part of dax;


/**
 * Thrown when there's a problem with WebGL.
 */
class WebGLException extends Exception {}


/**
 * Thrown when WebGL is not available on the system.
 */
class NoWebGLException extends WebGLException {}