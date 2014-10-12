#include "Python.h"

void *py_init_python() {
    /* sometimes Python needs to know about argc and argv to be happy */
    int _python_argc = 1;
    char *_python_argv[] = {
        "python",
    };

    Py_SetProgramName("python");
    Py_Initialize();
    PySys_SetArgv(_python_argc, _python_argv);  /* Tk needs this */
}

PyObject *py_eval(const char* p, int type) {
    PyObject *	main_module;
    PyObject *	globals;
    PyObject *	locals;
    PyObject *	py_result;
    int             context;
    /* doc:  if the module wasn't already loaded, you will get an empty
     * module object. */
    main_module = PyImport_AddModule("__main__");
    if(main_module == NULL) {
        printf("Error -- Import_AddModule of __main__ failed");
    }
    globals = PyModule_GetDict(main_module);
    locals = globals;
    context = (type == 0)
        ? Py_eval_input :
            (type == 1)
            ? Py_file_input
            : Py_single_input;
    py_result = PyRun_String(p, context, globals, locals);
    if (!py_result) {
        PyErr_Print();
        printf("Error -- py_eval raised an exception");
        return NULL;
    }
    return py_result;
}
