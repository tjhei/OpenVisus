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

#ifndef __VISUS_STRING_UTILS_H__
#define __VISUS_STRING_UTILS_H__

#include <Visus/Kernel.h>
#include <Visus/StringMap.h>

#include <vector>
#include <algorithm>
#include <iomanip>

namespace Visus {

//////////////////////////////////////////////////////////////////
class VISUS_KERNEL_API StringUtils
{
public:

  typedef FormatString format;

  //formatToHexadecimal
  static String formatToHexadecimal(int v)
  {
    std::ostringstream out;
    out << std::showbase << std::internal << std::setfill('0') << std::hex << std::setw(6) << v;
    return out.str();
  }

  //formatToHexadecimal
  static String formatToHexadecimal(Int64 v) {
    std::ostringstream out;
    out << std::showbase << std::internal << std::setfill('0') << std::hex << std::setw(8) << v;
    return out.str();
  }

  //formatToHexadecimal
  static String formatToHexadecimal(void* v) {
    return formatToHexadecimal((Int64)v);
  }

  //convertDoubleToString
  static String convertDoubleToString(double v, int precision = -1)
  {
    if (precision < 0)
    {
      return cstring(v);
    }
    else
    {
      std::ostringstream o;
      o << std::setprecision(precision) << std::fixed << v;
      return o.str();
    }
  }

  //ltrim
  static inline String ltrim(String ret, String spaces = " \t\r\n") {
    int i = (int)ret.find_first_not_of(spaces.c_str()); return i >= 0 ? ret.erase(0, i) : "";
  }

  //rtrim
  static inline String rtrim(String ret, String spaces = " \t\r\n") {
    int i = (int)ret.find_last_not_of(spaces.c_str()); return i >= 0 ? ret.erase(i + 1) : "";
  }

  //trim
  static inline String trim(String ret, String spaces = " \t\r\n") {
    return ltrim(rtrim(ret, spaces), spaces);
  }

  //reverse
  static inline String reverse(String ret) {
    std::reverse(ret.begin(), ret.end()); return ret;
  }

  //inline
  static inline String removeSpaces(String str) {
    str.erase(std::remove_if(str.begin(), str.end(), isspace), str.end());
    return str;
  }

  //toLower
  static String toLower(String ret);

  //toUpper

  static String toUpper(String ret);

  //find
  static inline int find(String src, String what) {
    return (int)src.find(what);
  }

  //contains
  static inline bool contains(String src, String what) {
    return find(src, what) >= 0;
  }

  //nextToken
  static inline String nextToken(String src, String separator) {
    int idx = find(src, separator); return idx >= 0 ? src.substr(idx + (int)separator.length()) : "";
  }

  //replaceFirst
  static inline String replaceFirst(String src, String what, String value) 
  {
    int idx = (int)src.find(what);
    return (idx < 0) ? (src) : (src.substr(0, idx) + value + src.substr(idx + what.length()));
  }

  //replaceAll
  static inline String replaceAll(String src, String what, String value) 
  {
    String ret; int m = (int)what.length();
    for (int idx = (int)src.find(what); idx >= 0; idx = (int)src.find(what))
    {
      ret = ret + src.substr(0, idx) + value; src = src.substr(idx + m);
    }
    return ret + src;
  }

  //startsWith
  static inline bool startsWith(String s, String what, bool caseSensitive = false)
  {
    int n = (int)s.length(), m = (int)what.length();
    if (n < m) return false;
    s = s.substr(0, m);
    return caseSensitive ? (s == what) : (toLower(s) == toLower(what));
  }

  //endsWith
  static inline bool endsWith(String s, String what, bool caseSensitive = false)
  {
    int n = (int)s.length(), m = (int)what.length();
    if (n < m) return false;
    s = s.substr(n - m);
    return caseSensitive ? (s == what) : (toLower(s) == toLower(what));
  }

  //tryParse
  static bool inline tryParse(String s, int& value)
  {
    std::istringstream iss(s);
    int temp; iss >> temp;
    if (iss.fail() || !iss.eof()) return false;
    value = temp;
    return true;
  }

  //tryParse
  static bool inline tryParse(String s, Int64& value)
  {
    std::istringstream iss(s);
    Int64 temp; iss >> temp;
    if (iss.fail() || !iss.eof()) return false;
    value = temp;
    return true;
  }

  //tryParse
  static inline bool tryParse(String s, double& value)
  {
    std::istringstream iss(s);
    double temp; iss >> temp;
    if (iss.fail() || !iss.eof()) return false;
    value = temp;
    return true;
  }

  //split
  static std::vector<String> split(String source, String separator = " ", bool bPurgeEmptyItems = true);

  //join
  static String join(std::vector<String> v, String separator = " ", String prefix = "", String suffix = "");

  //join
  template <typename T>
  static String join(std::vector<T> v, String separator = " ", String prefix = "", String suffix = "")
  {
    std::vector<String> tmp;
    for (auto it : v)
      tmp.push_back(cstring(it));
    return join(tmp, separator, prefix, suffix);
  }

  //combine
  static std::vector<String> combine(std::vector<String> a, String combinator, std::vector<String> b) {

    int N = (int)std::min(a.size(), b.size());
    std::vector<String> ret(N);
    for (int I = 0; I < N; I++)
      ret[I]=a[I]+combinator+b[I];
    return ret;
  }

  //decorateAll
  static std::vector<String> decorateAll(String prefix, std::vector<String> v, String postfix) {
    std::vector<String> ret;
    for (auto it : v)
      ret.push_back(prefix+it+postfix);
    return ret;
  }

  //getLines
  static std::vector<String> getLines(const String& s);

  //getNonEmptyLines
  static std::vector<String> getNonEmptyLines(const String& s);

  //getLinesAndPurgeComments
  static std::vector<String> getLinesAndPurgeComments(String source, String commentString);

  //base64Encode
  static String base64Encode(const String& input);

  //base64Decode
  static String base64Decode(const String& input);

  //sha256
  static String sha256(String input, String key);

  //sha1
  static String sha1(String input, String key);

  //md5
  static String md5(const String& input);

  //computeChecksum
  static String computeChecksum(const String& input)
  {
    return md5(input);
  }

  //encodeForFilename
  static String encodeForFilename(String value);

  // to encode/decode string in HTML format 
  static String removeEscapeChars(String value);

  // to encode/decode string in HTML format 
  static String addEscapeChars(String value);

  //getDateTimeForFilename
  static String getDateTimeForFilename();

  //example 1mb-> 1024*1024
  static Int64 getByteSizeFromString(String value);

  //example 1024 -> 1kb
  static String getStringFromByteSize(Int64 size);

private:

#if SWIG
  StringUtils();
#else
  StringUtils() = delete;
#endif
  
};


///////////////////////////////////////////////////////////////
class VISUS_KERNEL_API ParseStringParams
{
public:

  VISUS_CLASS(ParseStringParams)

  String    source;
  String    without_params;
  StringMap params;

  //constructor
  //Example leftpart?arg1=value1&arg2=value2
  ParseStringParams(String source, String question_sep = "?", String and_sep = "&", String equal_sep = "=");

};

} //namespace Visus

#endif //__VISUS_STRING_UTILS_H__

