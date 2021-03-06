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

#include <Visus/Db.h>
#include <Visus/Array.h>

#include <Visus/DatasetBitmask.h>
#include <Visus/LegacyDataset.h>
#include <Visus/DatasetArrayPlugin.h>
#include <Visus/PythonEngine.h>

namespace Visus {

bool DbModule::bAttached = false;

///////////////////////////////////////////////////////////////////////////////////////////
void DbModule::attach()
{
  if (bAttached)  
    return;
  
  VisusInfo() << "Attaching DbModule...";
  
  bAttached = true;

  KernelModule::attach();

  DatasetPluginFactory::allocSingleton();

  ArrayPlugins::getSingleton()->values.push_back(std::make_shared<DatasetArrayPlugin>());

  //VISUS_REGISTER_OBJECT_CLASS(Access);
  //VISUS_REGISTER_OBJECT_CLASS(FilterAccess);
  //VISUS_REGISTER_OBJECT_CLASS(MultiplexAccess);
  //VISUS_REGISTER_OBJECT_CLASS(ModVisusAccess);
  //VISUS_REGISTER_OBJECT_CLASS(RamAccess);
  //VISUS_REGISTER_OBJECT_CLASS(DiskAccess);
  //VISUS_REGISTER_OBJECT_CLASS(OnDemandAccess);
  //VISUS_REGISTER_OBJECT_CLASS(Dataset);

  VISUS_REGISTER_OBJECT_CLASS(LegacyDataset);

  VisusInfo() << "Attached DbModule";
}

//////////////////////////////////////////////
void DbModule::detach()
{
  if (!bAttached)  
    return;
  
  VisusInfo() << "Detatching DbModule...";
  
  bAttached = false;

  DatasetPluginFactory::releaseSingleton();

  KernelModule::detach();

  VisusInfo() << "Detatched DbModule.";
}

} //namespace Visus 

