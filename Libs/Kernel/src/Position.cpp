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

#include <Visus/Position.h>

namespace Visus {

//////////////////////////////////////////////////
Position Position::withoutTransformation() const
{
  if (!this->valid())
    return Position::invalid();

  Matrix T   = getTransformation();
  Box3d    box = getBox();

  Box3d ret = Box3d::invalid();
  for (int I = 0; I<8; I++)
    ret.addPoint(T * box.getPoint(I));

  return Position(ret);
}

//////////////////////////////////////////////////
Position Position::shrink(const Box3d& dst_box,const LinearMap& map,Position position) 
{
  const int unit_box_edges[12][2]=
  {
    {0,1}, {1,2}, {2,3}, {3,0},
    {4,5}, {5,6}, {6,7}, {7,4},
    {0,4}, {1,5}, {2,6}, {3,7}
  };

  if (!position.valid())
    return position;

  const LinearMap& T2(map);
  MatrixMap T1(position.getTransformation());
  Box3d       src_rvalue=position.getBox();

  Box3d shrinked_rvalue= Box3d::invalid();

  #define DIRECT(T2,T1,value)   (T2.applyDirectMap(T1.applyDirectMap(value)))
  #define INVERSE(T2,T1,value)  (T1.applyInverseMap(T2.applyInverseMap(value)))

  int query_dim=position.getBox().minsize()>0? 3 : 2;
  if (query_dim==2)
  {
    int slice_axis=-1;
    if (src_rvalue.p1.x==src_rvalue.p2.x) {if (slice_axis>=0) return Position::invalid();slice_axis=0;}
    if (src_rvalue.p1.y==src_rvalue.p2.y) {if (slice_axis>=0) return Position::invalid();slice_axis=1;}
    if (src_rvalue.p1.z==src_rvalue.p2.z) {if (slice_axis>=0) return Position::invalid();slice_axis=2;}
    VisusAssert(slice_axis>=0);

    VisusAssert(src_rvalue.p1[slice_axis]==src_rvalue.p2[slice_axis]);
    double slice_pos=src_rvalue.p1[slice_axis];

    Plane slice_planes[3]={Plane(1,0,0,-slice_pos),Plane(0,1,0,-slice_pos),Plane(0,0,1,-slice_pos)};

    //how the plane is transformed by <T> (i.e. go to screen)
    Plane slice_plane_in_screen=DIRECT(T2,T1,slice_planes[slice_axis]);
        
    //point classification
    double distances[8];

    //points belonging to the plane
    for (int I=0;I<8;I++)
    {
      Point3d p=dst_box.getPoint(I);
      distances[I]=slice_plane_in_screen.getDistance(p);
      if (!distances[I]) 
      {
        p=INVERSE(T2,T1,Point4d(p,1.0)).dropHomogeneousCoordinate();
        p[slice_axis]=slice_pos; //I know it must implicitely be on the Z plane! 
        shrinked_rvalue.addPoint(p);
      }
    }

    //split edges
    for (int E=0;E<12;E++)
    {
      int i1=unit_box_edges[E][0];double h1=distances[i1];
      int i2=unit_box_edges[E][1];double h2=distances[i2];
      if ((h1>0 && h2<0) || (h1<0 && h2>0))
      {
        Point3d p1=dst_box.getPoint(i1);h1=fabs(h1);
        Point3d p2=dst_box.getPoint(i2);h2=fabs(h2);
        double alpha =h2/(h1+h2);
        double beta  =h1/(h1+h2);
        Point3d p=INVERSE(T2,T1,Point4d(alpha*p1 + beta*p2,1.0)).dropHomogeneousCoordinate();
        p[slice_axis]=slice_pos; //I know it must implicitely be on the Z plane! 
        shrinked_rvalue.addPoint(p);
      }
    }
  }
  else
  {
    auto isPointInsideHull=[](const Point3d& point,const std::vector<Plane>& planes)
    {
		const double epsilon = 1e-4;
      bool bInside=true;
      for (int I=0;bInside && I<(int)planes.size();I++)
        bInside=planes[I].getDistance(point)<epsilon;
      return bInside;
    };

    //see http://www.gamedev.net/community/forums/topic.asp?topic_id=224689
    VisusAssert(query_dim==3);

    //the first polyhedra (i.e. position)
    Point3d V1[8]; for (int I=0;I<8;I++) V1[I]=src_rvalue.getPoint(I);
    std::vector<Plane> H1=src_rvalue.getPlanes();

    //the second polyhedra (transformed to be in the first polyhedra system, i.e. position)
    Point3d V2[8];for (int I=0;I<8;I++) 
      V2[I]=INVERSE(T2,T1,Point4d(dst_box.getPoint(I),1.0)).dropHomogeneousCoordinate();
  
    std::vector<Plane> H2=dst_box.getPlanes(); 
    for (int H=0;H<6;H++) 
      H2[H]=INVERSE(T2,T1,H2[H]);

    //point of the first (second) polyhedra inside second (first) polyhedra
    for (int V=0;V<8;V++) {if (isPointInsideHull(V1[V],H2)) {shrinked_rvalue.addPoint(V1[V]);}}
    for (int V=0;V<8;V++) {if (isPointInsideHull(V2[V],H1)) {shrinked_rvalue.addPoint(V2[V]);}}

    //intersection of first polydra edges with second polyhedral planes
    for (int H=0;H<6;H++)
    {
      double distances[8];
      for (int V=0;V<8;V++) distances[V]=H2[H].getDistance(V1[V]);
      
      for (int E=0;E<12;E++)
      {
        int i1=unit_box_edges[E][0];double h1=distances[i1];
        int i2=unit_box_edges[E][1];double h2=distances[i2];
        if ((h1>0 && h2<0) || (h1<0 && h2>0))
        {
          Point3d p1=V1[i1];h1=fabs(h1);
          Point3d p2=V1[i2];h2=fabs(h2);
          double alpha =h2/(h1+h2);
          double beta  =h1/(h1+h2);
          Point3d p=alpha*p1+beta*p2;
          if (isPointInsideHull(p,H2)) {shrinked_rvalue.addPoint(p);}
        }
      }
    }

    //intersection of second polyhedra edges with first polyhedral planes
    for (int H=0;H<6;H++)
    {
      double distances[8];
      for (int V=0;V<8;V++) distances[V]=H1[H].getDistance(V2[V]);
      
      for (int E=0;E<12;E++)
      {
        int i1=unit_box_edges[E][0];double h1=distances[i1];
        int i2=unit_box_edges[E][1];double h2=distances[i2];
        if ((h1>0 && h2<0) || (h1<0 && h2>0))
        {
          Point3d p1=V2[i1];h1=fabs(h1);
          Point3d p2=V2[i2];h2=fabs(h2);
          double alpha =h2/(h1+h2);
          double beta  =h1/(h1+h2);
          Point3d  p=alpha*p1+beta*p2;
          if (isPointInsideHull(p,H1)) {shrinked_rvalue.addPoint(p);}
        }
      }
    }
  }

  if (shrinked_rvalue.valid())
    shrinked_rvalue=shrinked_rvalue.getIntersection(src_rvalue);

  return Position(position.getTransformation(),shrinked_rvalue);

  #undef DIRECT
  #undef INVERSE

}

//////////////////////////////////////////////////
void Position::writeToObjectStream(ObjectStream& ostream)
{
  if (!valid())
    return;

  ostream.writeInline("pdim",cstring(pdim));

  if (!T.isIdentity())
  {
    ostream.pushContext("T");
    T.writeToObjectStream(ostream);
    ostream.popContext("T");
  }
  
  ostream.pushContext("box");
  this->box.writeToObjectStream(ostream);
  ostream.popContext("box");
}

//////////////////////////////////////////////////
void Position::readFromObjectStream(ObjectStream& istream)
{
  this->T=Matrix::identity();

  this->pdim=cint(istream.readInline("pdim"));

  if (istream.pushContext("T"))
  {
    this->T.readFromObjectStream(istream);
    istream.popContext("T");
  }

  if (istream.pushContext("box"))
  {
    this->box.readFromObjectStream(istream);
    istream.popContext("box");
  }
  
}


} //namespace Visus

