/*-----------------------------------------------------------------------------
Copyright(c) 2010 - 2018 ViSUS L.L.C.,
Scientific Computing and Imaging Institute of the University of Utah

ViSUS L.L.C., 50 W.Broadway, Ste. 300, 84101 - 2044 Salt Lake City, UT
University of Utah, 72 S Central Campus Dr, Room 3750, 84112 Salt Lake City, UT

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met :

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

For additional information about this project contact : pascucci@acm.org
For support : support@visus.net
-----------------------------------------------------------------------------*/

%module(directors="1") NonGuiOpenVisus

%include <VisusSwigCommon.i>


//__________________________________________________________
%{ 

//Kernel
#include <Visus/Visus.h>
#include <Visus/PythonEngine.h>
#include <Visus/Array.h>
#include <Visus/VisusConfig.h>

//Dataflow
#include <Visus/DataflowModule.h>
#include <Visus/DataflowMessage.h>
#include <Visus/DataflowPort.h>
#include <Visus/DataflowNode.h>
#include <Visus/Dataflow.h>

//Db
#include <Visus/Db.h>
#include <Visus/Access.h>
#include <Visus/BlockQuery.h>
#include <Visus/Query.h>

//Idx
#include <Visus/Idx.h>
#include <Visus/IdxFile.h>
#include <Visus/IdxDataset.h>
#include <Visus/IdxMultipleDataset.h>

//Nodes
#include <Visus/Nodes.h>
	
using namespace Visus;

//deleteNumPyArrayCapsule
static void deleteNumPyArrayCapsule(PyObject *capsule)
{
	SharedPtr<HeapMemory>* keep_heap_in_memory=(SharedPtr<HeapMemory>*)PyCapsule_GetPointer(capsule, NULL);
	delete keep_heap_in_memory;
}

%}

/////////////////////////////////////////////////////////////////////
//swig includes

//Kernel
ENABLE_SHARED_PTR(HeapMemory)
ENABLE_SHARED_PTR(DictObject)
ENABLE_SHARED_PTR(ObjectCreator)
ENABLE_SHARED_PTR(Object)
ENABLE_SHARED_PTR(StringTree)
ENABLE_SHARED_PTR(Array)
%newobject Visus::ObjectStream::readObject;
%newobject Visus::ObjectCreator::createInstance;
%newobject Visus::ObjectFactory::createInstance;
%newobject Visus::StringTreeEncoder::encode;
%newobject Visus::StringTreeEncoder::decode;
%template(BoolPtr) Visus::SharedPtr<bool>;
%template(VectorOfField) std::vector<Visus::Field>;
%template(VectorOfArray) std::vector<Visus::Array>;
%include <Visus/Visus.h>
%include <Visus/Kernel.h>
%include <Visus/StringMap.h>
%include <Visus/Log.h>
%include <Visus/HeapMemory.h>
%include <Visus/Singleton.h>
%include <Visus/Object.h>
%include <Visus/Aborted.h>
%include <Visus/StringTree.h>
%include <Visus/VisusConfig.h>
%include <Visus/Color.h>
%include <Visus/Point.h> 
  %template(Point2i)    Visus::Point2<int   > ;
  %template(Point2f)    Visus::Point2<float > ;
  %template(Point2d)    Visus::Point2<double> ;
  %template(Point3i)    Visus::Point3<int  >  ;
  %template(Point3f)    Visus::Point3<float>  ;
  %template(Point3d)    Visus::Point3<double> ;
  %template(Point4i)    Visus::Point4<int   > ;
  %template(Point4f)    Visus::Point4<float > ;
  %template(Point4d)    Visus::Point4<double> ;
  %template(PointNi)    Visus::PointN<int >   ;
  %template(PointNf)    Visus::PointN<float > ;
  %template(PointNd)    Visus::PointN<double> ;
  %template(NdPoint)    Visus::PointN< Visus::Int64 > ;
%include <Visus/Box.h>
  %template(Box3d)    Visus::Box3<double> ;
  %template(Box3i)    Visus::Box3<int> ;
  %template(BoxNd)    Visus::BoxN<double> ;
  %template(NdBox)    Visus::BoxN< Visus::Int64 >;
%include <Visus/Matrix.h>
%include <Visus/Position.h>
%include <Visus/Range.h>
%include <Visus/DType.h>
%include <Visus/Field.h>
%include <Visus/Array.h>

//Db
ENABLE_SHARED_PTR(Access)
ENABLE_SHARED_PTR(BlockQuery)
ENABLE_SHARED_PTR(Query)
ENABLE_SHARED_PTR(Dataset)
%include <Visus/Db.h>
%include <Visus/Access.h>
%include <Visus/LogicBox.h>
%include <Visus/BlockQuery.h>
%include <Visus/Query.h>
%include <Visus/DatasetBitmask.h>
%include <Visus/Dataset.h>

//Dataflow
ENABLE_SHARED_PTR(Dataflow)
ENABLE_SHARED_PTR(DataflowMessage)
ENABLE_SHARED_PTR(ReturnReceipt)
ENABLE_SHARED_PTR(NodeJob)
%apply SWIGTYPE *DISOWN_FOR_DIRECTOR { Visus::Node* disown };
%template(VectorNode) std::vector<Visus::Node*>;
%feature("director") Visus::Node;
%include <Visus/DataflowModule.h>
%include <Visus/DataflowMessage.h>
%include <Visus/DataflowPort.h>
%include <Visus/DataflowNode.h>
%include <Visus/Dataflow.h>

//Nodes
%include <Visus/Nodes.h>

//Idx
%include <Visus/Idx.h>
%include <Visus/IdxFile.h>
%include <Visus/IdxDataset.h>
%include <Visus/IdxMultipleDataset.h>

// _____________________________________________________
// init code 
%init %{

	//numpy does not work in windows/debug
	#if WIN32
		#if !defined(_DEBUG) || defined(SWIG_PYTHON_INTERPRETER_NO_DEBUG)
			import_array();
		#endif
	#else
		import_array();
	#endif
%}


// _____________________________________________________
// python code 

%pythoncode %{

# equivalent to VISUS_REGISTER_OBJECT_CLASS 
def VISUS_REGISTER_PYTHON_OBJECT_CLASS(object_name):

  class MyObjectCreator(ObjectCreator):

    # __init__
    def __init__(self,object_name):
      ObjectCreator.__init__(self)
      self.object_name=object_name

    # createInstance
    def createInstance(self):
      return eval(self.object_name+"()")

  ObjectFactory.getSingleton().registerObjectClass(object_name,object_name,MyObjectCreator(object_name))

%}


// _____________________________________________________
// extend Array

%extend Visus::Array {

  //operator[]
  Visus::Array operator[](int index) const {return $self->getComponent(index);}
  Visus::Array operator+(Visus::Array& other) const {return ArrayUtils::add(*self,other);}
  Visus::Array operator-(Visus::Array& other) const {return ArrayUtils::sub(*self,other);}
  Visus::Array operator*(Visus::Array& other) const {return ArrayUtils::mul(*self,other);}
  Visus::Array operator*(double coeff) const {return ArrayUtils::mul(*self,coeff);}
  Visus::Array operator/(Visus::Array& other) const {return ArrayUtils::div(*self,other);}
  Visus::Array operator/(double coeff) const {return ArrayUtils::div(*self,coeff);}
  Visus::Array& operator+=(Visus::Array& other)  {*self=ArrayUtils::add(*self,other); return *self;}
  Visus::Array& operator-=(Visus::Array& other)  {*self=ArrayUtils::sub(*self,other); return *self;}
  Visus::Array& operator*=(Visus::Array& other)  {*self=ArrayUtils::mul(*self,other); return *self;}
  Visus::Array& operator*=(double coeff) {*self=ArrayUtils::mul(*self,coeff); return *self;}
  Visus::Array& operator/=(Visus::Array& other)  {*self=ArrayUtils::div(*self,other); return *self;} 
  Visus::Array& operator/=(double coeff)  {*self=ArrayUtils::div(*self,coeff); return *self;}

  static Visus::Array fromVectorInt32(Visus::NdPoint dims, const std::vector<Visus::Int32>& vector) {
	return Visus::Array::fromVector<Visus::Int32>(dims, Visus::DTypes::INT32, vector);
  }

  static Visus::Array fromVectorFloat64(Visus::NdPoint dims, const std::vector<Visus::Float64>& vector) {
    return Visus::Array::fromVector<Visus::Float64>(dims, Visus::DTypes::FLOAT64, vector);
  }

  //asNumPy (the returned numpy will share the memory... see capsule code)
  PyObject* asNumPy() const
  {
    //in numpy the first dimension is the "upper dimension"
    //example:
    // a=array([[1,2,3],[4,5,6]])
    // print a.shape # return 2,3
    // print a[1,1]  # equivalent to print a[Y,X], return 5  
    npy_intp shape[VISUS_NDPOINT_DIM+1]; 
	int shape_dim=0;
    for (int I=VISUS_NDPOINT_DIM-1;I>=0;I--) {
		if ($self->dims[I]>1) 
		  shape[shape_dim++]=(npy_int)$self->dims[I];
    }

    int   ndtype        = $self->dtype.ncomponents();
    DType single_dtype  = $self->dtype.get(0);
    if (ndtype>1) shape[shape_dim++]=(npy_int)ndtype;
    int typenum;

    if      (single_dtype==(DTypes::UINT8  )) typenum=NPY_UINT8 ;
    else if (single_dtype==(DTypes::INT8   )) typenum=NPY_INT8  ;
    else if (single_dtype==(DTypes::UINT16 )) typenum=NPY_UINT16;
    else if (single_dtype==(DTypes::INT16  )) typenum=NPY_INT16 ;
    else if (single_dtype==(DTypes::UINT32 )) typenum=NPY_UINT32;
    else if (single_dtype==(DTypes::INT32  )) typenum=NPY_INT32 ;
    else if (single_dtype==(DTypes::UINT64 )) typenum=NPY_UINT64;
    else if (single_dtype==(DTypes::INT64  )) typenum=NPY_INT64 ;
    else if (single_dtype==(DTypes::FLOAT32)) typenum=NPY_FLOAT ;
    else if (single_dtype==(DTypes::FLOAT64)) typenum=NPY_DOUBLE;
    else {
		VisusInfo()<<"numpy type not supported "<<$self->dtype.toString();
		return nullptr;
	}

	//http://blog.enthought.com/python/numpy-arrays-with-pre-allocated-memory/#.W79FS-gzZtM
	//https://gitlab.onelab.info/gmsh/gmsh/commit/9cb49a8c372d2f7a48ee91ad2ca01c70f3b7cddf
	//NOTE: from documentatin: "...If data is passed to  PyArray_New, this memory must not be deallocated until the new array is deleted"
	auto data=(void*)$self->c_ptr();
	PyObject *ret = PyArray_New(&PyArray_Type, shape_dim, shape, typenum, NULL,data , 0, NPY_ARRAY_C_CONTIGUOUS | NPY_ARRAY_ALIGNED | NPY_ARRAY_WRITEABLE, NULL);
    PyArray_SetBaseObject((PyArrayObject*)ret, PyCapsule_New(new SharedPtr<HeapMemory>($self->heap), NULL, deleteNumPyArrayCapsule));
	return ret;
  }
  
  //constructor
  static Array fromNumPy(PyObject* obj)
  {
    if (!obj || !PyArray_Check((PyArrayObject*)obj)) 
	{
      SWIG_SetErrorMsg(PyExc_NotImplementedError,"input argument is not a numpy array\n");
	  return Array();
    }
    
    PyArrayObject* numpy_array = (PyArrayObject*) obj;

	//must be contiguos
    if (!PyArray_ISCONTIGUOUS(numpy_array)) {
      SWIG_SetErrorMsg(PyExc_NotImplementedError,"numpy array is null or not contiguous\n");
      return Array();
    }

    Uint8* c_ptr=(Uint8*)numpy_array->data;
    
    NdPoint dims=NdPoint::one(numpy_array->nd);
    for (int I=0;I<numpy_array->nd;I++)
      dims[I]=numpy_array->dimensions[numpy_array->nd-1-I];

    DType dtype;
    if      (PyArray_TYPE(numpy_array)==NPY_UINT8  ) dtype=(DTypes::UINT8  );
    else if (PyArray_TYPE(numpy_array)==NPY_INT8   ) dtype=(DTypes::INT8   );
    else if (PyArray_TYPE(numpy_array)==NPY_UINT16 ) dtype=(DTypes::UINT16 );
    else if (PyArray_TYPE(numpy_array)==NPY_INT16  ) dtype=(DTypes::INT16  );
    else if (PyArray_TYPE(numpy_array)==NPY_UINT32 ) dtype=(DTypes::UINT32 );
    else if (PyArray_TYPE(numpy_array)==NPY_INT32  ) dtype=(DTypes::INT32  );
    else if (PyArray_TYPE(numpy_array)==NPY_UINT64 ) dtype=(DTypes::UINT64 );
    else if (PyArray_TYPE(numpy_array)==NPY_INT64  ) dtype=(DTypes::INT64  );
    else if (PyArray_TYPE(numpy_array)==NPY_FLOAT  ) dtype=(DTypes::FLOAT32);
    else if (PyArray_TYPE(numpy_array)==NPY_DOUBLE ) dtype=(DTypes::FLOAT64);
    else {
      SWIG_SetErrorMsg(PyExc_NotImplementedError,"cannot guess visus dtype from numpy array_type\n");
      return Array();
    }

	//cannot share the memory
	if (!(numpy_array->flags & NPY_OWNDATA) || PyArray_BASE(numpy_array)!=NULL)
	{
	  //Array ret(dims,dtype);
	  //memcpy(ret.c_ptr(),,ret.c_size());
	  //return ret;
      SWIG_SetErrorMsg(PyExc_NotImplementedError,"numpy cannot share its internal memory\n");
      return Array();
	}

	auto heap=HeapMemory::createManaged((Uint8*)PyArray_DATA(numpy_array),dtype.getByteSize(dims));
	numpy_array->flags &= ~NPY_OWNDATA; //Heap has taken the property
	PyArray_SetBaseObject((PyArrayObject*)numpy_array, PyCapsule_New(new SharedPtr<HeapMemory>(heap), NULL, deleteNumPyArrayCapsule));

	return Array(dims,dtype,heap);
  }

  %pythoncode %{
    def __rmul__(self, v):
      return self.__mul__(v)
  %}
};
