# libmdbx-msvc

Prebuilt static `libmdbx.lib` and headers for Windows (MSVC).  
This repository provides a ready-to-use build of [libmdbx](https://github.com/erthink/libmdbx) for projects using MSVC.

## ⚠️ Current Status

**Experimental / Non-functional:**  
At the moment, this repository includes an *unsuccessful attempt* to build a Windows-compatible static `.lib` from the MinGW-based `.dll`. The project is not yet usable as intended for MSVC.

We're still investigating a proper cross-compilation or static linking workflow that works reliably across different setups. Contributions and suggestions are welcome.

## 🔧 Description

This package includes:
- Precompiled `libmdbx.lib` (built with MSVC)
- Original MDBX headers (`mdbx.h`, etc.)
- Compatible with C++17 or later
- Suitable for use with vcpkg, Conan, CMake, etc.

## 📦 Structure

```
libmdbx-msvc/
├── include/
│   └── mdbx.h
├── lib/
│   └── mdbx.lib
├── LICENSE
└── README.md
```

## 🛠 Build Info

- Compiler: MSVC (x64)
- Static runtime: `/MT`
- Build type: Release
- No dependencies

## ⚖️ License

This package is provided under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).  
Original library: © 2019–2025 by [Leonid Yuriev](https://github.com/erthink), licensed under Apache 2.0.

## 📥 Usage

Just add `include/` to your header path and link with `lib/mdbx.lib`.

In CMake:
```cmake
target_include_directories(myapp PRIVATE path/to/libmdbx-msvc/include)
target_link_libraries(myapp PRIVATE path/to/libmdbx-msvc/lib/mdbx.lib)
```

## 📁 Optional: vcpkg.json

If you want to use this as a local port in vcpkg:

```json
{
  "name": "libmdbx-msvc",
  "version": "1.0.0",
  "description": "Prebuilt MDBX static library for MSVC (Windows)",
  "homepage": "https://github.com/NewYaroslav/libmdbx-msvc",
  "license": "Apache-2.0"
}
```
