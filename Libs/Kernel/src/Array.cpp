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

#include <Visus/Array.h>
#include <Visus/Color.h>
#include <Visus/Utils.h>

#ifdef WIN32
#pragma warning(disable:4244)
#pragma warning(disable:4018)
#endif

namespace Visus {

VISUS_IMPLEMENT_SINGLETON_CLASS(ArrayPlugins)

///////////////////////////////////////////////////////////////////////////////
void Array::writeToObjectStream(ObjectStream& ostream)
{
  if (!this->url.empty())
  {
    ostream.write("url", this->url);
    return;
  }

  ostream.write("data", this->heap->base64Encode());
  ostream.write("dims", dims.toString());

  if (!layout.empty())
    ostream.write("layout", layout);

  ostream.pushContext("dtype");
  dtype.writeToObjectStream(ostream);
  ostream.popContext("dtype");

  ostream.pushContext("bounds");
  bounds.writeToObjectStream(ostream);
  ostream.popContext("bounds");

  if (clipping.valid())
  {
    ostream.pushContext("clipping");
    clipping.writeToObjectStream(ostream);
    ostream.popContext("clipping");
  }

  //mask
  //texture;
}

///////////////////////////////////////////////////////////////////////////////
void Array::readFromObjectStream(ObjectStream& istream)
{
  String url = istream.read("url");

  if (!url.empty())
  {
    auto tmp=ArrayUtils::loadImage(url);
    if (!tmp)
      ThrowException(StringUtils::format() << "cannot load image " << url);

    *this=tmp;
    return;
  }

  this->heap=HeapMemory::base64Decode(istream.read("data"));
  if (!this->heap)
    ThrowException("cannot base64Decode data");

  this->dims = NdPoint::parseDims(istream.read("dims"));
  this->layout = istream.read("layout");

  istream.pushContext("dtype");
  dtype.readFromObjectStream(istream);
  istream.popContext("dtype");

  istream.pushContext("bounds");
  bounds.readFromObjectStream(istream);
  istream.popContext("bounds");

  clipping = Position::invalid();
  if (istream.pushContext("clipping"))
  {
    clipping.readFromObjectStream(istream);
    istream.popContext("clipping");
  }

  //mask
  //texture;
}


} //namespace Visus

