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

#ifndef VISUS_LOCAL_COORDINATE_SYSTEM_H
#define VISUS_LOCAL_COORDINATE_SYSTEM_H

#include <Visus/Kernel.h>
#include <Visus/Point.h>
#include <Visus/Position.h>

namespace Visus {

//////////////////////////////////////////////////////////////////
class VISUS_KERNEL_API LocalCoordinateSystem : public Object
{
public:

  VISUS_CLASS(LocalCoordinateSystem)

  //constructor
  LocalCoordinateSystem(Point3d x_=Point3d(1,0,0),Point3d y_=Point3d(0,1,0),Point3d z_=Point3d(0,0,1),Point3d c_=Point3d(0,0,0));

  //constructor
  LocalCoordinateSystem(Point3d center_,int axis);

  //constructor
  LocalCoordinateSystem(const Matrix& T);

  //constructor
  LocalCoordinateSystem(const Position& pos);

  //constructor
  LocalCoordinateSystem(const Matrix& T,LocalCoordinateSystem& other) : LocalCoordinateSystem(T*other.toMatrix()) {
  }

  //invalid
  static LocalCoordinateSystem invalid()
  {return LocalCoordinateSystem(Point3d(),Point3d(),Point3d());}

  //valid
  inline bool valid() const
  {return x.module2() && y.module2() && z.module2();}

  //getCenter
  inline const Point3d& getCenter() const
  {return c;}

  inline const Point3d& getXAxis() const {return x;}
  inline const Point3d& getYAxis() const {return y;}
  inline const Point3d& getZAxis() const {return z;}

  //getAxis
  inline const Point3d& getAxis(int axis) const
  {return (axis==0)? (x) : (axis==1?y:z);}

  //setAxis
  inline void setAxis(int axis,const Point3d& value) 
  {((axis==0)? (x) : (axis==1?y:z))=value;}

  //getPointRelativeToCenter
  inline Point3d getPointRelativeToCenter(Point3d coeff) const
  {return c + coeff.x*x + coeff.y*y + coeff.z*z;}

  //getBoxPoint
  inline Point3d getBoxPoint(int idx) const
  {const Box3d box(Point3d(-1,-1,-1),Point3d(+1,+1,+1));return getPointRelativeToCenter(box.getPoint(idx));}

  //getAxisPoint
  inline Point3d getAxisPoint(int axis,double coeff) const
  {return c + coeff*getAxis(axis);}

  inline Point3d getMinAxisPoint(int axis) const {return getAxisPoint(axis,-1);}
  inline Point3d getMaxAxisPoint(int axis) const {return getAxisPoint(axis,+1);}
  inline Point3d getMinXPoint() const {return getMinAxisPoint(0);}
  inline Point3d getMaxXPoint() const {return getMaxAxisPoint(0);}
  inline Point3d getMinYPoint() const {return getMinAxisPoint(1);}
  inline Point3d getMaxYPoint() const {return getMaxAxisPoint(1);}
  inline Point3d getMinZPoint() const {return getMinAxisPoint(2);}
  inline Point3d getMaxZPoint() const {return getMaxAxisPoint(2);}

  //getPlane
  inline Plane getPlane(int axis) const {return Plane(getAxis(axis),getCenter());}
  inline Plane getXPlane()        const {return getPlane(0);}
  inline Plane getYPlane()        const {return getPlane(1);}
  inline Plane getZPlane()        const {return getPlane(2);}
  
  //scale
  inline LocalCoordinateSystem scale(Point3d vs) const
  {return LocalCoordinateSystem(vs.x*getXAxis(),vs.y*getYAxis(),vs.z*getZAxis(),getCenter());}

  //translate
  inline LocalCoordinateSystem translate(Point3d vt) const
  {return LocalCoordinateSystem(getXAxis(),getYAxis(),getZAxis(),getCenter()+vt);}

  //operator==
  inline bool operator==(const LocalCoordinateSystem& other) const
  {return c==other.c && x==other.x && y==other.y && z==other.z;}

  //operator==
  inline bool operator!=(const LocalCoordinateSystem& other) const
  {return !(*this==other);}

  //toMatrix
  Matrix4 toMatrix() const {
    return Matrix4(
      x[0],y[0],z[0],c[0],
      x[1],y[1],z[1],c[1],
      x[2],y[2],z[2],c[2],
      0,0,0,1);
  }

  //toUniformSize
  LocalCoordinateSystem toUniformSize() const;

public:


  //writeToObjectStream
  virtual void writeToObjectStream(ObjectStream& ostream) override;

  //readFromObjectStream
  virtual void readFromObjectStream(ObjectStream& istream) override;

private:

  Point3d c,x,y,z;

};


} //namespace Visus

#endif //VISUS_LOCAL_COORDINATE_SYSTEM_H
