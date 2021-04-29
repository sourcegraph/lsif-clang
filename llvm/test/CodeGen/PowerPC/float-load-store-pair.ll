; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs < %s -mcpu=pwr9 -mtriple=powerpc64le-ibm-linux| FileCheck %s

; This file verifies that for a given floating point load / store pair,
; if the load value isn't used by any other operations,
; then consider transforming the pair to integer load / store operations

@a1 = local_unnamed_addr global double 0.000000e+00, align 8
@a2 = local_unnamed_addr global double 0.000000e+00, align 8
@a3 = local_unnamed_addr global double 0.000000e+00, align 8
@a4 = local_unnamed_addr global double 0.000000e+00, align 8
@a5 = local_unnamed_addr global double 0.000000e+00, align 8
@a6 = local_unnamed_addr global double 0.000000e+00, align 8
@a7 = local_unnamed_addr global double 0.000000e+00, align 8
@a8 = local_unnamed_addr global double 0.000000e+00, align 8
@a9 = local_unnamed_addr global double 0.000000e+00, align 8
@a10 = local_unnamed_addr global double 0.000000e+00, align 8
@a11 = local_unnamed_addr global double 0.000000e+00, align 8
@a12 = local_unnamed_addr global double 0.000000e+00, align 8
@a13 = local_unnamed_addr global double 0.000000e+00, align 8
@a14 = local_unnamed_addr global double 0.000000e+00, align 8
@a15 = local_unnamed_addr global double 0.000000e+00, align 8
@a16 = local_unnamed_addr global ppc_fp128 0xM00000000000000000000000000000000, align 16
@a17 = local_unnamed_addr global fp128 0xL00000000000000000000000000000000, align 16

; Because this test function is trying to pass float argument by stack,
; so the fpr is only used to load/store float argument
define signext i32 @test() nounwind {
; CHECK-LABEL: test:
; CHECK:       # %bb.0:
; CHECK-NEXT:    mflr 0
; CHECK-NEXT:    std 0, 16(1)
; CHECK-NEXT:    stdu 1, -192(1)
; CHECK-NEXT:    addis 3, 2, a1@toc@ha
; CHECK-NEXT:    lfd 1, a1@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a2@toc@ha
; CHECK-NEXT:    lfd 2, a2@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a3@toc@ha
; CHECK-NEXT:    lfd 3, a3@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a4@toc@ha
; CHECK-NEXT:    lfd 4, a4@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a5@toc@ha
; CHECK-NEXT:    lfd 5, a5@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a6@toc@ha
; CHECK-NEXT:    lfd 6, a6@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a7@toc@ha
; CHECK-NEXT:    lfd 7, a7@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a8@toc@ha
; CHECK-NEXT:    lfd 8, a8@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a9@toc@ha
; CHECK-NEXT:    lfd 9, a9@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a10@toc@ha
; CHECK-NEXT:    lfd 10, a10@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a11@toc@ha
; CHECK-NEXT:    lfd 11, a11@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a12@toc@ha
; CHECK-NEXT:    addis 5, 2, a16@toc@ha
; CHECK-NEXT:    addis 6, 2, a17@toc@ha
; CHECK-NEXT:    addi 6, 6, a17@toc@l
; CHECK-NEXT:    lxvx 34, 0, 6
; CHECK-NEXT:    lfd 12, a12@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a13@toc@ha
; CHECK-NEXT:    addi 5, 5, a16@toc@l
; CHECK-NEXT:    addis 4, 2, a15@toc@ha
; CHECK-NEXT:    lxvx 0, 0, 5
; CHECK-NEXT:    ld 4, a15@toc@l(4)
; CHECK-NEXT:    li 5, 152
; CHECK-NEXT:    lfd 13, a13@toc@l(3)
; CHECK-NEXT:    addis 3, 2, a14@toc@ha
; CHECK-NEXT:    ld 3, a14@toc@l(3)
; CHECK-NEXT:    stxvx 0, 1, 5
; CHECK-NEXT:    std 4, 144(1)
; CHECK-NEXT:    std 3, 136(1)
; CHECK-NEXT:    bl _Z3fooddddddddddddddd
; CHECK-NEXT:    nop
; CHECK-NEXT:    li 3, 0
; CHECK-NEXT:    addi 1, 1, 192
; CHECK-NEXT:    ld 0, 16(1)
; CHECK-NEXT:    mtlr 0
; CHECK-NEXT:    blr
%1 = load double, double* @a1, align 8
%2 = load double, double* @a2, align 8
%3 = load double, double* @a3, align 8
%4 = load double, double* @a4, align 8
%5 = load double, double* @a5, align 8
%6 = load double, double* @a6, align 8
%7 = load double, double* @a7, align 8
%8 = load double, double* @a8, align 8
%9 = load double, double* @a9, align 8
%10 = load double, double* @a10, align 8
%11 = load double, double* @a11, align 8
%12 = load double, double* @a12, align 8
%13 = load double, double* @a13, align 8
%14 = load double, double* @a14, align 8
%15 = load double, double* @a15, align 8
%16 = load ppc_fp128, ppc_fp128* @a16, align 16
%17 = load fp128, fp128* @a17, align 16
tail call void @_Z3fooddddddddddddddd(double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, ppc_fp128 %16, fp128 %17)
ret i32 0
}

declare void @_Z3fooddddddddddddddd(double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, ppc_fp128, fp128)
