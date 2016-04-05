/* Created by "go tool cgo" - DO NOT EDIT. */

/* package command-line-arguments */

/* Start of preamble from import "C" comments.  */




/* End of preamble from import "C" comments.  */


/* Start of boilerplate cgo prologue.  */

#ifndef GO_CGO_PROLOGUE_H
#define GO_CGO_PROLOGUE_H

typedef signed char GoInt8;
typedef unsigned char GoUint8;
typedef short GoInt16;
typedef unsigned short GoUint16;
typedef int GoInt32;
typedef unsigned int GoUint32;
typedef long long GoInt64;
typedef unsigned long long GoUint64;
typedef GoInt32 GoInt;
typedef GoUint32 GoUint;
typedef __SIZE_TYPE__ GoUintptr;
typedef float GoFloat32;
typedef double GoFloat64;
typedef float _Complex GoComplex64;
typedef double _Complex GoComplex128;

/*
  static assertion to make sure the file is being used on architecture
  at least with matching size of GoInt.
*/

typedef struct { const char *p; GoInt n; } GoString;
typedef void *GoMap;
typedef void *GoChan;
typedef struct { void *t; void *v; } GoInterface;
typedef struct { void *data; GoInt len; GoInt cap; } GoSlice;

#endif

/* End of boilerplate cgo prologue.  */

#ifdef __cplusplus
extern "C" {
#endif


extern GoUint64 CBID();

extern void Free(GoUint64 p0);

extern GoUint64 NewDomain(char* p0);

extern GoUint64 Subdomain(GoUint64 p0, char* p1);

extern void SetToken(GoUint64 p0, char* p1);

extern char* Receive(GoUint64 p0);

extern void Join(GoUint64 p0, GoUint64 p1, GoUint64 p2);

extern void Subscribe(GoUint64 p0, char* p1, GoUint64 p2, GoUint64 p3, GoUint64 p4, char* p5);

extern void Register(GoUint64 p0, char* p1, GoUint64 p2, GoUint64 p3, GoUint64 p4, char* p5);

extern void Publish(GoUint64 p0, char* p1, GoUint64 p2, GoUint64 p3, char* p4);

extern void Call(GoUint64 p0, char* p1, GoUint64 p2, GoUint64 p3, char* p4);

extern void Yield(GoUint64 p0, GoUint64 p1, char* p2);

extern void CallExpects(GoUint64 p0, GoUint64 p1, char* p2);

extern void Unsubscribe(GoUint64 p0, char* p1, GoUint64 p2, GoUint64 p3);

extern void Unregister(GoUint64 p0, char* p1, GoUint64 p2, GoUint64 p3);

extern void Leave(GoUint64 p0);

extern void MantleSetLogLevelOff();

extern void MantleSetLogLevelApp();

extern void MantleSetLogLevelErr();

extern void MantleSetLogLevelWarn();

extern void MantleSetLogLevelInfo();

extern void MantleSetLogLevelDebug();

extern void MantleSetFabricDev();

extern void MantleSetFabricSandbox();

extern void MantleSetFabricProduction();

extern void MantleSetFabricLocal();

extern void MantleSetFabric(char* p0);

extern void MantleSetRegistrar(char* p0);

extern void MantleApplication(char* p0);

extern void MantleDebug(char* p0);

extern void MantleInfo(char* p0);

extern void MantleWarn(char* p0);

extern void MantleError(char* p0);

extern void MantleSetCuminStrict();

extern void MantleSetCuminLoose();

extern void MantleSetCuminOff();

#ifdef __cplusplus
}
#endif
