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

int py_instance_check(PyObject *obj) {
    return ((obj->ob_type->tp_flags & Py_TPFLAGS_HEAPTYPE) || PyInstance_Check(obj));
}

int py_int_check(PyObject *obj) {
    return PyInt_Check(obj);
}

int py_float_check(PyObject *obj) {
    return PyFloat_Check(obj);
}

int py_unicode_check(PyObject *obj) {
    return PyUnicode_Check(obj);
}

int py_string_check(PyObject *obj) {
    return PyString_Check(obj);
}

int py_sequence_check(PyObject *obj) {
    return PySequence_Check(obj);
}

int py_mapping_check(PyObject *obj) {
    return PyMapping_Check(obj);
}

int py_is_none(PyObject *obj) {
    return obj == Py_None;
}

long py_int_as_long(PyObject *obj) {
    return PyInt_AsLong(obj);
}

double py_float_as_double(PyObject *obj) {
    return PyFloat_AsDouble(obj);
}

PyObject *py_int_to_py(long num) {
    return PyInt_FromLong(num);
}

PyObject *py_float_to_py(double num) {
    return PyFloat_FromDouble(num);
}

PyObject *py_str_to_py(int len, char *str) {
    return PyUnicode_DecodeUTF8(str, len, "replace");
}

PyObject *py_buf_to_py(int len, char *buf) {
    return PyString_FromStringAndSize(buf, len);
}

char *py_unicode_to_char_star(PyObject *obj) {
    PyObject * const string = PyUnicode_AsUTF8String(obj);    /* new reference */
    if (!string) {
        return NULL;
    }
    char * const str = PyString_AsString(string);
    Py_DECREF(string);
    return str;
}

Py_ssize_t py_string_to_buf(PyObject *obj, char **buf) {
    PyObject * const string = PyObject_Str(obj);    /* new reference */
    if (!string) {
        return 0;
    }
    Py_ssize_t length;
    PyString_AsStringAndSize(obj, buf, &length);
    Py_DECREF(string);
    return length;
}

int py_sequence_length(PyObject *obj) {
    return PySequence_Length(obj);
}

PyObject *py_sequence_get_item(PyObject *obj, int item) {
    return PySequence_GetItem(obj, item);
}

PyObject *py_mapping_items(PyObject *obj) {
    return PyMapping_Items(obj);
}

PyObject *py_tuple_new(int len) {
    return PyTuple_New(len);
}

void py_tuple_set_item(PyObject *tuple, int i, PyObject *item) {
    PyTuple_SetItem(tuple, i, item);
}

PyObject *py_list_new(int len) {
    return PyList_New(len);
}

void py_list_set_item(PyObject *list, int i, PyObject *item) {
    PyList_SetItem(list, i, item);
}

PyObject *py_dict_new() {
    return PyDict_New();
}

void py_dict_set_item(PyObject *dict, PyObject *key, PyObject *item) {
    PyDict_SetItem(dict, key, item);
}

PyObject *py_none() {
    Py_INCREF(Py_None);
    return Py_None;
}

void py_dec_ref(PyObject *obj) {
    Py_DECREF(obj);
}

void py_inc_ref(PyObject *obj) {
    Py_INCREF(obj);
}

PyObject *py_call_function(char *pkg, char *name, PyObject *args) {
    int i;
    PyObject * const mod       = PyImport_AddModule(pkg);
    PyObject * const dict      = PyModule_GetDict(mod);
    PyObject * const func      = PyMapping_GetItemString(dict, name);
    PyObject *py_retval = NULL;

    py_retval = PyObject_CallObject(func, args);
    Py_DECREF(func);
    Py_DECREF(args);

    return py_retval;
}

PyObject *py_call_method(PyObject *obj, char *name, PyObject *args) {
    PyObject *method = PyObject_GetAttrString(obj, name);
    PyObject *py_retval = PyObject_CallObject(method, args);
    Py_DECREF(method);
    Py_DECREF(args);

    return py_retval;
}
