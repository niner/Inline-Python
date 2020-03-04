#include "Python.h"
#include "datetime.h"


void PyInit_perl6(void);

PyObject *(*call_p6_object)(int, PyObject *, PyObject **);
PyObject *(*call_p6_method)(int, char * , PyObject *, PyObject **);

void py_init_python(PyObject *(*call_object)(int, PyObject *, PyObject **), PyObject *(*call_method)(int, char * , PyObject *, PyObject **)) {
    /* sometimes Python needs to know about argc and argv to be happy */
    int _python_argc = 1;
    wchar_t** _python_argv = PyMem_Malloc(sizeof(wchar_t*)* _python_argc);
    _python_argv[0] = L"";

    call_p6_object = call_object;
    call_p6_method = call_method;

    Py_SetProgramName(L"python");
    Py_Initialize();

    PyInit_perl6();

    PySys_SetArgv(_python_argc, _python_argv);  /* Tk needs this */
    PyDateTime_IMPORT;
}

PyObject *perl6object;

void py_init_perl6object(void) {
    PyObject *main_module = PyImport_AddModule("__main__");
    PyObject *globals = PyModule_GetDict(main_module);
    perl6object = PyDict_GetItemString(globals, "Perl6Object");
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
    py_result = PyRun_StringFlags(p, context, globals, locals, NULL);
    return py_result;
}

PyObject *py_import(char *module) {
    return PyImport_ImportModule(module);
}

int py_instance_check(PyObject *obj) {
    return ((obj->ob_type->tp_flags & Py_TPFLAGS_HEAPTYPE) || !PyType_Check(obj) || PyDate_Check(obj));
}

int py_is_instance(PyObject *obj, PyObject *class) {
    if (obj == NULL || class == NULL) {
        return 0;
    }
    return PyObject_IsInstance(obj, class);
}

int py_int_check(PyObject *obj) {
    return PyLong_Check(obj);
}

int py_float_check(PyObject *obj) {
    return PyFloat_Check(obj);
}

int py_unicode_check(PyObject *obj) {
    return PyUnicode_Check(obj);
}

int py_buffer_check(PyObject *obj) {
    return PyObject_CheckBuffer(obj);
}

int py_sequence_check(PyObject *obj) {
    return PySequence_Check(obj);
}

int py_mapping_check(PyObject *obj) {
    return PyMapping_Check(obj);
}

int py_callable_check(PyObject *obj) {
    return PyFunction_Check(obj) || PyMethod_Check(obj);
}

int py_is_none(PyObject *obj) {
    return obj == Py_None;
}

long py_int_as_long(PyObject *obj) {
    return PyLong_AsLong(obj);
}

double py_float_as_double(PyObject *obj) {
    return PyFloat_AsDouble(obj);
}

PyObject *py_int_to_py(long num) {
    return PyLong_FromLong(num);
}

PyObject *py_float_to_py(double num) {
    return PyFloat_FromDouble(num);
}

PyObject *py_str_to_py(int len, char *str) {
    return PyUnicode_DecodeUTF8(str, len, "replace");
}

PyObject *py_buf_to_py(int len, char *buf) {
    return PyUnicode_FromStringAndSize(buf, len);
}

PyObject *py_unicode_as_utf8_string(PyObject *obj) {
    return PyUnicode_AsUTF8String(obj);
}

char *py_string_as_string(PyObject *obj) {
    return PyUnicode_AsUTF8(obj);
}

Py_ssize_t py_string_to_buf(PyObject *obj, char **buf) {
    Py_ssize_t length;

    *buf = PyUnicode_AsUTF8AndSize(obj, &length);
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

PyObject *py_dict_new(void) {
    return PyDict_New();
}

void py_dict_set_item(PyObject *dict, PyObject *key, PyObject *item) {
    PyDict_SetItem(dict, key, item);
}

PyObject *py_none(void) {
    Py_INCREF(Py_None);
    return Py_None;
}

void py_dec_ref(PyObject *obj) {
    Py_DECREF(obj);
}

void py_inc_ref(PyObject *obj) {
    Py_INCREF(obj);
}

PyObject *py_getattr(PyObject *obj, char *name) {
    if (name == NULL)
        return NULL;
    return PyObject_GetAttrString(obj, name);
}

PyObject *py_dir(PyObject *obj) {
    return PyObject_Dir(obj);
}

PyObject *py_call_function(char *pkg, char *name, PyObject *args) {
    PyObject * const mod       = PyImport_AddModule(pkg);
    PyObject * const dict      = PyModule_GetDict(mod);
    PyObject * const func      = PyMapping_GetItemString(dict, name);
    PyObject *py_retval = NULL;

    if (func == NULL) {
        PyErr_Format(PyExc_NameError, "name '%s' is not defined", name);
        goto cleanup;
    }

    py_retval = PyObject_CallObject(func, args);

    Py_DECREF(func);
    cleanup:
    Py_DECREF(args);

    return py_retval;
}

PyObject *py_call_function_kw(char *pkg, char *name, PyObject *args, PyObject *kw) {
    PyObject * const mod       = PyImport_AddModule(pkg);
    PyObject * const dict      = PyModule_GetDict(mod);
    PyObject * const func      = PyMapping_GetItemString(dict, name);
    PyObject *py_retval = NULL;

    if (func == NULL) {
        PyErr_Format(PyExc_NameError, "name '%s' is not defined", name);
        goto cleanup;
    }

    py_retval = PyObject_Call(func, args, kw);

    Py_DECREF(func);
    cleanup:
    Py_DECREF(args);
    Py_DECREF(kw);

    return py_retval;
}

void py_fetch_error(PyObject **exception) {
    /* ex_type, ex_value, ex_trace, ex_message */
    PyErr_Fetch(&exception[0], &exception[1], &exception[2]);
    if (exception[0] == NULL)
        return;
    PyErr_NormalizeException(&exception[0], &exception[1], &exception[2]);
    exception[3] = PyObject_Str(exception[1]); /* new reference */
}

void py_raise_missing_method(PyObject *obj, char *name) {
    PyObject *class = PyObject_GetAttrString(obj, "__class__");
    if (class) {
        PyObject *class_name = PyObject_GetAttrString(class, "__name__");
        char *c_class_name = PyUnicode_AsUTF8(class_name);
        PyErr_Format(PyExc_NameError, "%s instance has no attribute '%s'", c_class_name, name);
        Py_DECREF(class_name);
        Py_DECREF(class);
    }
    else {
        PyErr_Format(PyExc_NameError, "instance has no attribute '%s'", name);
    }
}

PyObject *py_call_static_method_kw(char *pkg, char *class, char *name, PyObject *args, PyObject *kw) {
    PyObject * const mod  = PyImport_AddModule(pkg);
    PyObject * const dict = PyModule_GetDict(mod);
    PyObject * const obj  = PyMapping_GetItemString(dict, class);
    PyObject *method = PyObject_GetAttrString(obj, name);
    if (method == NULL) {
        py_raise_missing_method(obj, name);
        goto cleanup;
    }
    PyObject *py_retval = PyObject_Call(method, args, kw);
    Py_DECREF(method);

    cleanup:
    Py_DECREF(args);
    Py_DECREF(kw);

    return py_retval;
}

PyObject *py_call_static_method(char *pkg, char *class, char *name, PyObject *args) {
    PyObject * const mod  = PyImport_AddModule(pkg);
    PyObject * const dict = PyModule_GetDict(mod);
    PyObject * const obj  = PyMapping_GetItemString(dict, class);
    PyObject *method = PyObject_GetAttrString(obj, name);
    if (method == NULL) {
        py_raise_missing_method(obj, name);
        goto cleanup;
    }
    PyObject *py_retval = PyObject_CallObject(method, args);
    Py_DECREF(method);

    cleanup:
    Py_DECREF(args);

    return py_retval;
}

PyObject *py_call_method(PyObject *obj, char *name, PyObject *args) {
    PyObject *method = PyObject_GetAttrString(obj, name);
    if (method == NULL) {
        py_raise_missing_method(obj, name);
        goto cleanup;
    }
    PyObject *py_retval = PyObject_CallObject(method, args);
    Py_DECREF(method);

    cleanup:
    Py_DECREF(args);

    return py_retval;
}

PyObject *py_call_method_kw(PyObject *obj, char *name, PyObject *args, PyObject *kw) {
    PyObject *method = PyObject_GetAttrString(obj, name);
    if (method == NULL) {
        py_raise_missing_method(obj, name);
        goto cleanup;
    }
    PyObject *py_retval = PyObject_Call(method, args, kw);
    Py_DECREF(method);

    cleanup:
    Py_DECREF(args);

    return py_retval;
}

static PyObject *perl6_call(PyObject *self, PyObject *args) {
    PyObject * const index  = PyTuple_GetItem(args, 0);
    PyObject * const params = PyTuple_GetItem(args, 1);
    PyObject * error = NULL;

    PyObject *retval = call_p6_object(PyLong_AsLong(index), params, &error);
    if (error != NULL) {
        PyErr_SetObject(PyExc_Exception, error);
        return NULL;
    }
    return retval;
}

static PyObject *perl6_invoke(PyObject *self, PyObject *args) {
    PyObject * const index  = PyTuple_GetItem(args, 0);
    PyObject * const name   = PyTuple_GetItem(args, 1);
    PyObject * const params = PyTuple_GetItem(args, 2);
    PyObject * error = NULL;

    Py_ssize_t length;
    char * buf = PyUnicode_AsUTF8AndSize(name, &length);

    PyObject *retval = call_p6_method(PyLong_AsLong(index), buf, params, &error);
    if (error != NULL) {
        PyErr_SetObject(PyExc_Exception, error);
        return NULL;
    }
    return retval;
}

static PyMethodDef perl_functions[] = {
    {"call",   perl6_call,   METH_VARARGS, PyDoc_STR("invoke(object, *args) -> retval")},
    {"invoke", perl6_invoke, METH_VARARGS, PyDoc_STR("invoke(object, method_name, *args) -> retval")},
    {NULL,              NULL}                /* sentinel */
};

void PyInit_perl6(void){
    /* Create the module and add the functions */
    static struct PyModuleDef perl_module = {
        PyModuleDef_HEAD_INIT,
        "perl6",
        "perl6 -- Access a Perl 6 interpreter transparently",
        -1, /* m_size */
        perl_functions, /* m_methods */
        NULL, /* m_slots */
        NULL, /* m_traverse */
        NULL, /* m_clear */
        NULL /* m_free */
    };
    (void) PyModule_Create(&perl_module);
}
