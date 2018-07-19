
# //////////////////////////////////////////////////////////////////////////
macro(SetupCMake)

	set(CMAKE_CXX_STANDARD 11)

	# enable parallel building
	set(CMAKE_NUM_PROCS 8)          

	# use folders to organize projects                           
	set_property(GLOBAL PROPERTY USE_FOLDERS ON)    

	# save libraries and binaries in the same directory        
	set(EXECUTABLE_OUTPUT_PATH  ${CMAKE_BINARY_DIR})           
	set(LIBRARY_OUTPUT_PATH     ${CMAKE_BINARY_DIR})	

	if (NOT WIN32)
      
		set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE CACHE BOOL "" FORCE)
		set(CMAKE_SKIP_BUILD_RPATH         TRUE  CACHE BOOL "" FORCE)
		set(CMAKE_SKIP_RPATH               TRUE  CACHE BOOL "" FORCE)
		set(CMAKE_SKIP_INSTALL_RPATH       TRUE  CACHE BOOL "" FORCE)

		mark_as_advanced(CMAKE_BUILD_WITH_INSTALL_RPATH)
		mark_as_advanced(CMAKE_SKIP_BUILD_RPATH)
		mark_as_advanced(CMAKE_SKIP_RPATH)
		mark_as_advanced(CMAKE_SKIP_INSTALL_RPATH)

		if (APPLE)
			# NOT USING qt deploy because it's kind of unusable
			# you can check the rpath by 
			#   otool -l filename | grep -i -A2 rpath
			#   otool -L filename
		 	set(CMAKE_MACOSX_RPATH FALSE CACHE BOOL "" FORCE)
			mark_as_advanced(CMAKE_MACOSX_RPATH)
		else()
			# check dependencies
			# ldd filename
		endif()

	endif()

	if (WIN32)

		# enable parallel building
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")

		# huge file are generated by swig
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")

		# see http://msdn.microsoft.com/en-us/library/windows/desktop/ms683219(v=vs.85).aspx
		add_definitions(-DPSAPI_VERSION=1)

		# increse number of file descriptors
		add_definitions(-DFD_SETSIZE=4096)

		add_definitions(-D_CRT_SECURE_NO_WARNINGS )

		add_definitions(-DWIN32_LEAN_AND_MEAN)

		# Enable PDB generation for all release build configurations.
		# VC++ compiler and linker options taken from this article:
		# see https://msdn.microsoft.com/en-us/library/fsk896zz.aspx
		set(CMAKE_C_FLAGS_RELEASE   "${CMAKE_C_FLAGS_RELEASE}   /Zi")
		set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")

		set(CMAKE_EXE_LINKER_FLAGS_RELEASE    "${CMAKE_EXE_LINKER_FLAGS_RELEASE}    /DEBUG /OPT:REF /OPT:ICF /INCREMENTAL:NO")
		set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "${CMAKE_MODULE_LINKER_FLAGS_RELEASE} /DEBUG /OPT:REF /OPT:ICF /INCREMENTAL:NO")
		set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /DEBUG /OPT:REF /OPT:ICF /INCREMENTAL:NO")

	elseif (APPLE)

		# force executable to bundle
		set(CMAKE_MACOSX_BUNDLE YES)

		# suppress some warnings
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-variable -Wno-reorder")

	else ()

		# allow the user to choose between Release and Debug
		if(NOT CMAKE_BUILD_TYPE)
		  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: Debug Release" FORCE)
		endif()

		if (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
		  add_definitions(-D_DEBUG=1)
		endif()

		# enable 64 bit file support (see http://learn-from-the-guru.blogspot.it/2008/02/large-file-support-in-linux-for-cc.html)
		add_definitions(-D_FILE_OFFSET_BITS=64)

		# -Wno-attributes to suppress spurious "type attributes ignored after type is already defined" messages 
		# see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=39159
		set(CMAKE_C_FLAGS    "${CMAKE_C_FLAGS}   -fPIC -Wno-attributes")
		set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -fPIC -Wno-attributes")

		# add usual include directories
		include_directories("/usr/local/include")
		include_directories("/usr/include")

	endif()

  if (NOT DISABLE_OPENMP)
	  find_package(OpenMP)
	  if (OpenMP_FOUND)
		  set(CMAKE_C_FLAGS          "${CMAKE_C_FLAGS}          ${OpenMP_C_FLAGS}")
		  set(CMAKE_CXX_FLAGS        "${CMAKE_CXX_FLAGS}        ${OpenMP_CXX_FLAGS}")
		  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
		  MESSAGE(STATUS "OpenMP found")
	  else()
	    MESSAGE(STATUS "OpenMP not found")
	  endif()
	else()
	  MESSAGE(STATUS "OpenMP disabled")
	endif()
	
endmacro()


# //////////////////////////////////////////////////////////////////////////
macro(AddExternalApp name SourceDir BinaryDir)

	if (WIN32 OR APPLE)
		set(CMAKE_GENERATOR_ARGUMENT -G"${CMAKE_GENERATOR}")
	else()
		set(CMAKE_GENERATOR_ARGUMENT -G"\"${CMAKE_GENERATOR}\"")
	endif()

	add_custom_target(${name} 
		COMMAND "${CMAKE_COMMAND}"  "${CMAKE_GENERATOR_ARGUMENT}" -H"${SourceDir}/"  -B"${BinaryDir}/"  -DQt5_DIR="${Qt5_DIR}"
		COMMAND "${CMAKE_COMMAND}"  --build "${BinaryDir}/" --config ${CMAKE_BUILD_TYPE})
		
	set_target_properties(${name} PROPERTIES FOLDER CMakeTargets/)

endmacro()

# //////////////////////////////////////////////////////////////////////////
macro(Win32AddImportedLibrary name include_dir debug_lib release_lib debug_dlls release_dlls)
	add_library(${name} SHARED IMPORTED GLOBAL)
	set_target_properties(${name} PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${include_dir}")
	set_property(TARGET ${name} APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug;Release;RelWithDebInfo")
	set_target_properties(${name} PROPERTIES IMPORTED_IMPLIB_DEBUG           ${debug_lib})
	set_target_properties(${name} PROPERTIES IMPORTED_IMPLIB_RELEASE         ${release_lib})    
	set_target_properties(${name} PROPERTIES IMPORTED_IMPLIB_RELWITHDEBINFO  ${release_lib}) 
	
	foreach(it ${debug_dlls})
		file(COPY ${it} DESTINATION ${LIBRARY_OUTPUT_PATH}/Debug)
	endforeach()
	
	foreach(it ${release_dlls})
		file(COPY ${it} DESTINATION ${LIBRARY_OUTPUT_PATH}/RelWithDebInfo)
		file(COPY ${it} DESTINATION ${LIBRARY_OUTPUT_PATH}/Release)
	endforeach()	
	
endmacro()

# //////////////////////////////////////////////////////////////////////////
macro(Win32CopyDllToBuild target debug_dll release_dll)

	ADD_CUSTOM_COMMAND(TARGET ${target} POST_BUILD COMMAND ${CMAKE_COMMAND}  -E 
		$<$<CONFIG:Debug>:copy>  $<$<CONFIG:Debug>:${debug_dll}> $<$<CONFIG:Debug>:${LIBRARY_OUTPUT_PATH}/Debug>
		$<$<CONFIG:Release>:echo>  $<$<CONFIG:Release>:"no command">
		$<$<CONFIG:RelWithDebInfo>:echo> $<$<CONFIG:RelWithDebInfo>:"no command">
	)
		
	ADD_CUSTOM_COMMAND(TARGET ${target} POST_BUILD COMMAND  ${CMAKE_COMMAND}  -E 
		$<$<CONFIG:Debug>:echo>  $<$<CONFIG:Debug>:"no command">
		$<$<CONFIG:Release>:copy> $<$<CONFIG:Release>:${release_dll}> $<$<CONFIG:Release>:${LIBRARY_OUTPUT_PATH}/Release>
		$<$<CONFIG:RelWithDebInfo>:echo> $<$<CONFIG:RelWithDebInfo>:"no command">
	)
		
	ADD_CUSTOM_COMMAND(TARGET ${target} POST_BUILD COMMAND  ${CMAKE_COMMAND}  -E 
		$<$<CONFIG:Debug>:echo>  $<$<CONFIG:Debug>:"no command">
		$<$<CONFIG:Release>:echo> $<$<CONFIG:Release>:"no command">
		$<$<CONFIG:RelWithDebInfo>:copy> $<$<CONFIG:RelWithDebInfo>:${release_dll}> $<$<CONFIG:RelWithDebInfo>:${LIBRARY_OUTPUT_PATH}/RelWithDebInfo>
	)		
		
endmacro()


# ///////////////////////////////////////////////////
macro(SetupSwig)

  find_package(SWIG REQUIRED)
  include(${SWIG_USE_FILE})
  set(CMAKE_SWIG_OUTDIR ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR})
  set(CMAKE_SWIG_FLAGS "")
  
  set(SWIG_FLAGS "")
  set(SWIG_FLAGS "${SWIG_FLAGS};-threads")
  set(SWIG_FLAGS "${SWIG_FLAGS};-extranative")
  
  if (NUMPY_FOUND)
  	set(SWIG_FLAGS "${SWIG_FLAGS};-DNUMPY_FOUND")
  endif()

endmacro()

# ///////////////////////////////////////////////////
macro(AddSwigLibrary Name SwigFile)

	set(NamePy ${Name}Py)

	#prevents rebuild every time make is called
	set_property(SOURCE ${SwigFile} PROPERTY SWIG_MODULE_NAME ${NamePy})

	set_source_files_properties(${SwigFile} PROPERTIES CPLUSPLUS ON)
	set_source_files_properties(${SwigFile} PROPERTIES SWIG_FLAGS  "${SWIG_FLAGS}")

	if (CMAKE_VERSION VERSION_LESS "3.8")
		swig_add_module(${NamePy} python ${SwigFile})
	else()
		swig_add_library(${NamePy} LANGUAGE python SOURCES ${SwigFile})
	endif()

	if (TARGET _${NamePy})
	  set(_target_name_ _${NamePy})
	elseif (TARGET ${NamePy})
	  set(_target_name_ ${NamePy})
	else()
	  message("FATAL ERROR, cannot find target py name")
	endif()

	if (WIN32)
		set_target_properties(${_target_name_}
	      PROPERTIES
	      COMPILE_PDB_NAME_DEBUG          ${_target_name_}_d
	      COMPILE_PDB_NAME_RELEASE        ${_target_name_}
	      COMPILE_PDB_NAME_MINSIZEREL     ${_target_name_}
	      COMPILE_PDB_NAME_RELWITHDEBINFO ${_target_name_})
	endif()
	
   target_link_libraries(${_target_name_} PUBLIC ${Name})

	InstallLibrary(${_target_name_})

	target_include_directories(${_target_name_} PUBLIC ${PYTHON_INCLUDE_DIRS})
	
	if (NUMPY_FOUND)
   		target_include_directories(${_target_name_} PRIVATE ${NUMPY_INCLUDE_DIR})
   		target_compile_definitions(${_target_name_} PRIVATE NUMPY_FOUND)
   endif()

	if(WIN32)
		set_target_properties(${_target_name_} PROPERTIES DEBUG_POSTFIX  "_d")
		target_compile_definitions(${_target_name_}  PRIVATE /W0)
	endif()

	# anaconda is statically linking python library inside its executable, so I cannot link in order to avoid duplicated symbols
	# see https://groups.google.com/a/continuum.io/forum/#!topic/anaconda/057P4uNWyCU
	if (APPLE AND PYTHON_EXECUTABLE)
		string(FIND "${PYTHON_EXECUTABLE}" "anaconda" is_anaconda)
		if ("${is_anaconda}" GREATER -1)
			set_target_properties(${_target_name_} PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
		else()
			target_link_libraries(${_target_name_} PUBLIC ${PYTHON_LIBRARY})
		endif()
	endif()

	set_target_properties(${_target_name_} PROPERTIES FOLDER ${CMAKE_FOLDER_PREFIX}Swig/)

	if (NOT WIN32)
		set_target_properties(${_target_name_} PROPERTIES COMPILE_FLAGS "${BUILD_FLAGS} -w")
	endif()

endmacro()


# //////////////////////////////////////////////////////////////////////////
macro(FindGitRevision)
	find_program(GIT_CMD git REQUIRED)
	find_package_handle_standard_args(GIT REQUIRED_VARS GIT_CMD)
	execute_process(COMMAND ${GIT_CMD} rev-parse --short HEAD WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} OUTPUT_VARIABLE GIT_REVISION OUTPUT_STRIP_TRAILING_WHITESPACE)
	message(STATUS "Current GIT_REVISION ${GIT_REVISION}")
endmacro()

# //////////////////////////////////////////////////////////////////////////
macro(FindVCPKGDir)
	set(VCPKG_DIR ${CMAKE_TOOLCHAIN_FILE}/../../../installed/${VCPKG_TARGET_TRIPLET})
	get_filename_component(VCPKG_DIR ${VCPKG_DIR} REALPATH)	
endmacro()


# /////////////////////////////////////////////////////////////
macro(DisableAllWarnings)

	set(CMAKE_C_WARNING_LEVEL   0)
	set(CMAKE_CXX_WARNING_LEVEL 0)
	
	if(WIN32)
		set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   /W0")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W0")
	else()
		set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -w")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
	endif()
endmacro()



# //////////////////////////////////////////////////////////////////////////
macro(AddCTest Name Command WorkingDirectory)

	add_test(NAME ${Name} WORKING_DIRECTORY "${WorkingDirectory}" COMMAND "${Command}" ${ARGN})

	if (WIN32)
		set_tests_properties(${Name} PROPERTIES ENVIRONMENT "CTEST_OUTPUT_ON_FAILURE=1;PYTHONPATH=${CMAKE_BINARY_DIR}/$<CONFIG>")
	elseif(APPLE)
		set_tests_properties(${Name} PROPERTIES ENVIRONMENT "CTEST_OUTPUT_ON_FAILURE=1;PYTHONPATH=${CMAKE_BINARY_DIR}/$<CONFIG>")
	else()
		set_tests_properties(${Name} PROPERTIES ENVIRONMENT "CTEST_OUTPUT_ON_FAILURE=1;PYTHONPATH=${CMAKE_BINARY_DIR};LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}")
	endif()

endmacro()


# ///////////////////////////////////////////////////
macro(AddLibrary Name)
	add_library(${Name} ${ARGN})
	set_target_properties(${Name} PROPERTIES FOLDER "${CMAKE_FOLDER_PREFIX}")
	string(TOUPPER ${Name} __upper_case__name__)
	target_compile_definitions(${Name}  PRIVATE VISUS_BUILDING_${__upper_case__name__}=1)
	target_include_directories(${Name}  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)
	if (WIN32)
	 	set_target_properties(${Name}
	      PROPERTIES
	      COMPILE_PDB_NAME_DEBUG          ${Name}
	      COMPILE_PDB_NAME_RELEASE        ${Name}
	      COMPILE_PDB_NAME_MINSIZEREL     ${Name}
	      COMPILE_PDB_NAME_RELWITHDEBINFO ${Name})
	endif()
	InstallLibrary(${Name})
endmacro()

# ///////////////////////////////////////////////////
macro(AddExecutable Name)
	add_executable(${Name} ${ARGN})
	set_target_properties(${Name} PROPERTIES FOLDER "${CMAKE_FOLDER_PREFIX}Executable/")
	if (WIN32)
	 	set_target_properties(${Name}
	      PROPERTIES
	      COMPILE_PDB_NAME_DEBUG          ${Name}
	      COMPILE_PDB_NAME_RELEASE        ${Name}
	      COMPILE_PDB_NAME_MINSIZEREL     ${Name}
	      COMPILE_PDB_NAME_RELWITHDEBINFO ${Name})
	endif()
	InstallExecutable(${Name})
endmacro()



# ///////////////////////////////////////////////////
macro(InstallLibrary Name)
 
	if (NOT VISUS_IS_SUBMODULE)
	
		if (WIN32 OR APPLE)
	
			install(TARGETS ${Name}  CONFIGURATIONS DEBUG          LIBRARY DESTINATION debug/bin RUNTIME DESTINATION debug/bin BUNDLE DESTINATION debug/bin ARCHIVE DESTINATION debug/lib)
			install(TARGETS ${Name}  CONFIGURATIONS RELEASE        LIBRARY DESTINATION bin       RUNTIME DESTINATION bin       BUNDLE DESTINATION bin       ARCHIVE DESTINATION lib)	
			install(TARGETS ${Name}  CONFIGURATIONS RELWITHDEBINFO LIBRARY DESTINATION bin       RUNTIME DESTINATION bin       BUNDLE DESTINATION bin       ARCHIVE DESTINATION lib)
						
			if (WIN32)
				install(FILES $<TARGET_PDB_FILE:${Name}> CONFIGURATIONS DEBUG          DESTINATION debug/bin )
				install(FILES $<TARGET_PDB_FILE:${Name}> CONFIGURATIONS RELEASE        DESTINATION bin       )
				install(FILES $<TARGET_PDB_FILE:${Name}> CONFIGURATIONS RELWITHDEBINFO DESTINATION bin       )
			endif()
			
		else()
			install(TARGETS ${Name} LIBRARY DESTINATION bin RUNTIME DESTINATION bin BUNDLE DESTINATION bin ARCHIVE DESTINATION lib)
		endif()
	endif()

endmacro()


# ///////////////////////////////////////////////////
macro(InstallExecutable Name)

	if (NOT VISUS_IS_SUBMODULE)
	
		if (WIN32 OR APPLE)
	
			install(TARGETS ${Name} CONFIGURATIONS DEBUG          BUNDLE     DESTINATION  debug/bin RUNTIME    DESTINATION  debug/bin )		
			install(TARGETS ${Name} CONFIGURATIONS RELEASE        BUNDLE     DESTINATION  bin       RUNTIME    DESTINATION  bin)			
			install(TARGETS ${Name} CONFIGURATIONS RELWITHDEBINFO BUNDLE     DESTINATION  bin       RUNTIME    DESTINATION  bin)						
	
			if (WIN32)
				install(FILES $<TARGET_PDB_FILE:${Name}> CONFIGURATIONS  DEBUG          DESTINATION debug/bin )
				install(FILES $<TARGET_PDB_FILE:${Name}> CONFIGURATIONS  RELEASE        DESTINATION bin       )
				install(FILES $<TARGET_PDB_FILE:${Name}> CONFIGURATIONS  RELWITHDEBINFO DESTINATION bin       )
			endif()
		else()
			
			install(TARGETS ${Name} BUNDLE DESTINATION  bin RUNTIME DESTINATION  bin)			
		endif()
	endif()

endmacro()

# ///////////////////////////////////////////////////
macro(InstallBuildFiles Pattern Destination)

	if (WIN32 OR APPLE)
		install(CODE "
			FILE(GLOB __files__ ${CMAKE_BINARY_DIR}/\${CMAKE_INSTALL_CONFIG_NAME}/${Pattern})
			FILE(INSTALL \${__files__} DESTINATION ${CMAKE_INSTALL_PREFIX}/${Destination})
		")
	else()
		install(CODE "
			FILE(GLOB __files__ ${CMAKE_BINARY_DIR}/${Pattern})
			FILE(INSTALL \${__files__} DESTINATION ${CMAKE_INSTALL_PREFIX}/${Destination})
		")
	endif()
endmacro()




