; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S < %s -instcombine | FileCheck %s
; RUN: opt -S < %s -passes=instcombine | FileCheck %s

; TODO: Simplify to "ret cond".
define i1 @test_direct_implication(i1 %cond) {
; CHECK-LABEL: @test_direct_implication(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    br label [[MERGE:%.*]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    [[RET:%.*]] = phi i1 [ true, [[IF_TRUE]] ], [ false, [[IF_FALSE]] ]
; CHECK-NEXT:    ret i1 [[RET]]
;
entry:
  br i1 %cond, label %if.true, label %if.false

if.true:
  br label %merge

if.false:
  br label %merge

merge:
  %ret = phi i1 [true, %if.true], [false, %if.false]
  ret i1 %ret
}

; TODO: Simplify to "ret !cond".
define i1 @test_inverted_implication(i1 %cond) {
; CHECK-LABEL: @test_inverted_implication(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    br label [[MERGE:%.*]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    [[RET:%.*]] = phi i1 [ false, [[IF_TRUE]] ], [ true, [[IF_FALSE]] ]
; CHECK-NEXT:    ret i1 [[RET]]
;
entry:
  br i1 %cond, label %if.true, label %if.false

if.true:
  br label %merge

if.false:
  br label %merge

merge:
  %ret = phi i1 [false, %if.true], [true, %if.false]
  ret i1 %ret
}

; TODO: Simplify to "ret cond".
define i1 @test_direct_implication_complex_cfg(i1 %cond, i32 %cnt1) {
; CHECK-LABEL: @test_direct_implication_complex_cfg(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    br label [[LOOP1:%.*]]
; CHECK:       loop1:
; CHECK-NEXT:    [[IV1:%.*]] = phi i32 [ 0, [[IF_TRUE]] ], [ [[IV1_NEXT:%.*]], [[LOOP1]] ]
; CHECK-NEXT:    [[IV1_NEXT]] = add i32 [[IV1]], 1
; CHECK-NEXT:    [[LOOP_COND_1:%.*]] = icmp slt i32 [[IV1_NEXT]], [[CNT1:%.*]]
; CHECK-NEXT:    br i1 [[LOOP_COND_1]], label [[LOOP1]], label [[IF_TRUE_END:%.*]]
; CHECK:       if.true.end:
; CHECK-NEXT:    br label [[MERGE:%.*]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    [[RET:%.*]] = phi i1 [ true, [[IF_TRUE_END]] ], [ false, [[IF_FALSE]] ]
; CHECK-NEXT:    ret i1 [[RET]]
;
entry:
  br i1 %cond, label %if.true, label %if.false

if.true:
  br label %loop1

loop1:
  %iv1 = phi i32 [0, %if.true], [%iv1.next, %loop1]
  %iv1.next = add i32 %iv1, 1
  %loop.cond.1 = icmp slt i32 %iv1.next, %cnt1
  br i1 %loop.cond.1, label %loop1, label %if.true.end

if.true.end:
  br label %merge

if.false:
  br label %merge

merge:
  %ret = phi i1 [true, %if.true.end], [false, %if.false]
  ret i1 %ret
}

; TODO: Simplify to "ret !cond".
define i1 @test_inverted_implication_complex_cfg(i1 %cond, i32 %cnt1) {
; CHECK-LABEL: @test_inverted_implication_complex_cfg(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    br label [[LOOP1:%.*]]
; CHECK:       loop1:
; CHECK-NEXT:    [[IV1:%.*]] = phi i32 [ 0, [[IF_TRUE]] ], [ [[IV1_NEXT:%.*]], [[LOOP1]] ]
; CHECK-NEXT:    [[IV1_NEXT]] = add i32 [[IV1]], 1
; CHECK-NEXT:    [[LOOP_COND_1:%.*]] = icmp slt i32 [[IV1_NEXT]], [[CNT1:%.*]]
; CHECK-NEXT:    br i1 [[LOOP_COND_1]], label [[LOOP1]], label [[IF_TRUE_END:%.*]]
; CHECK:       if.true.end:
; CHECK-NEXT:    br label [[MERGE:%.*]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    [[RET:%.*]] = phi i1 [ false, [[IF_TRUE_END]] ], [ true, [[IF_FALSE]] ]
; CHECK-NEXT:    ret i1 [[RET]]
;
entry:
  br i1 %cond, label %if.true, label %if.false

if.true:
  br label %loop1

loop1:
  %iv1 = phi i32 [0, %if.true], [%iv1.next, %loop1]
  %iv1.next = add i32 %iv1, 1
  %loop.cond.1 = icmp slt i32 %iv1.next, %cnt1
  br i1 %loop.cond.1, label %loop1, label %if.true.end

if.true.end:
  br label %merge

if.false:
  br label %merge

merge:
  %ret = phi i1 [false, %if.true.end], [true, %if.false]
  ret i1 %ret
}
