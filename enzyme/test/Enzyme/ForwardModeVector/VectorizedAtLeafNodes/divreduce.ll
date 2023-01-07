; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -enzyme-vectorize-at-leaf-nodes -mem2reg -simplifycfg -early-cse-memssa -instsimplify -correlated-propagation -adce -S | FileCheck %s

declare <3 x double> @__enzyme_fwddiff(i8*, ...)


; Function Attrs: norecurse nounwind readonly uwtable
define double @alldiv(double* nocapture readonly %A, i64 %N, double %start) {
entry:
  br label %loop

loop:                                                ; preds = %9, %5
  %i = phi i64 [ 0, %entry ], [ %next, %loop ]
  %reduce = phi double [ %start, %entry ], [ %div, %loop ]
  %gep = getelementptr inbounds double, double* %A, i64 %i
  %ld = load double, double* %gep, align 8, !tbaa !2
  %div = fdiv double %reduce, %ld
  %next = add nuw nsw i64 %i, 1
  %cmp = icmp eq i64 %next, %N
  br i1 %cmp, label %end, label %loop

end:                                                ; preds = %9, %3
  ret double %div
}

define double @alldiv2(double* nocapture readonly %A, i64 %N) {
entry:
  br label %loop

loop:                                                ; preds = %9, %5
  %i = phi i64 [ 0, %entry ], [ %next, %loop ]
  %reduce = phi double [ 2.000000e+00, %entry ], [ %div, %loop ]
  %gep = getelementptr inbounds double, double* %A, i64 %i
  %ld = load double, double* %gep, align 8, !tbaa !2
  %div = fdiv double %reduce, %ld
  %next = add nuw nsw i64 %i, 1
  %cmp = icmp eq i64 %next, %N
  br i1 %cmp, label %end, label %loop

end:                                                ; preds = %9, %3
  ret double %div
}

; Function Attrs: nounwind uwtable
define <3 x double> @main(double* %A, <3 x double>* %dA, i64 %N, double %start) {
  %r = call <3 x double> (i8*, ...) @__enzyme_fwddiff(i8* bitcast (double (double*, i64, double)* @alldiv to i8*), metadata !"enzyme_width", i64 3, double* %A, <3 x double>* %dA, i64 %N, double %start, <3 x double> <double 1.0, double 2.0, double 3.0>)
  %r2 = call <3 x double> (i8*, ...) @__enzyme_fwddiff(i8* bitcast (double (double*, i64)* @alldiv2 to i8*), metadata !"enzyme_width", i64 3, double* %A, <3 x double>* %dA, i64 %N)
  ret <3 x double> %r
}

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"Ubuntu clang version 10.0.1-++20200809072545+ef32c611aa2-1~exp1~20200809173142.193"}
!2 = !{!3, !3, i64 0}
!3 = !{!"double", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"any pointer", !4, i64 0}


; CHECK: define internal <3 x double> @fwddiffe3alldiv(double* nocapture readonly %A, <3 x double>* %"A'", i64 %N, double %start, <3 x double> %"start'")
; CHECK-NEXT: entry:
; CHECK-NEXT:   %0 = extractelement <3 x double> %"start'", i64 0
; CHECK-NEXT:   %1 = extractelement <3 x double> %"start'", i64 1
; CHECK-NEXT:   %2 = extractelement <3 x double> %"start'", i64 2
; CHECK-NEXT:   br label %loop

; CHECK: loop:                                             ; preds = %loop, %entry
; CHECK-NEXT:   %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
; CHECK-NEXT:   %3 = phi {{(fast )?}}double [ %0, %entry ], [ %14, %loop ]
; CHECK-NEXT:   %4 = phi {{(fast )?}}double [ %1, %entry ], [ %15, %loop ]
; CHECK-NEXT:   %5 = phi {{(fast )?}}double [ %2, %entry ], [ %16, %loop ]
; CHECK-NEXT:   %reduce = phi double [ %start, %entry ], [ %div, %loop ]
; CHECK-NEXT:   %6 = insertelement <3 x double> undef, double %3, i32 0
; CHECK-NEXT:   %7 = insertelement <3 x double> %6, double %4, i32 1
; CHECK-NEXT:   %8 = insertelement <3 x double> %7, double %5, i32 2
; CHECK-NEXT:   %iv.next = add nuw nsw i64 %iv, 1
; CHECK-NEXT:   %"gep'ipg" = getelementptr inbounds <3 x double>, <3 x double>* %"A'", i64 %iv
; CHECK-NEXT:   %gep = getelementptr inbounds double, double* %A, i64 %iv
; CHECK-NEXT:   %"ld'ipl" = load <3 x double>, <3 x double>* %"gep'ipg", align 8, !tbaa !2
; CHECK-NEXT:   %ld = load double, double* %gep, align 8, !tbaa !2
; CHECK-NEXT:   %div = fdiv double %reduce, %ld
; CHECK-NEXT:   %.splatinsert = insertelement <3 x double> {{(poison|undef)}}, double %reduce, i32 0
; CHECK-NEXT:   %.splat = shufflevector <3 x double> %.splatinsert, <3 x double> {{(poison|undef)}}, <3 x i32> zeroinitializer
; CHECK-NEXT:   %.splatinsert1 = insertelement <3 x double> {{(poison|undef)}}, double %ld, i32 0
; CHECK-NEXT:   %.splat2 = shufflevector <3 x double> %.splatinsert1, <3 x double> {{(poison|undef)}}, <3 x i32> zeroinitializer
; CHECK-NEXT:   %9 = fmul fast <3 x double> %8, %.splat2
; CHECK-NEXT:   %10 = fmul fast <3 x double> %.splat, %"ld'ipl"
; CHECK-NEXT:   %11 = fsub fast <3 x double> %9, %10
; CHECK-NEXT:   %12 = fmul fast double %ld, %ld
; CHECK-NEXT:   %.splatinsert3 = insertelement <3 x double> {{(poison|undef)}}, double %12, i32 0
; CHECK-NEXT:   %.splat4 = shufflevector <3 x double> %.splatinsert3, <3 x double> {{(poison|undef)}}, <3 x i32> zeroinitializer
; CHECK-NEXT:   %13 = fdiv fast <3 x double> %11, %.splat4
; CHECK-NEXT:   %cmp = icmp eq i64 %iv.next, %N
; CHECK-NEXT:   %14 = extractelement <3 x double> %13, i64 0
; CHECK-NEXT:   %15 = extractelement <3 x double> %13, i64 1
; CHECK-NEXT:   %16 = extractelement <3 x double> %13, i64 2
; CHECK-NEXT:   br i1 %cmp, label %end, label %loop

; CHECK: end:                                              ; preds = %loop
; CHECK-NEXT:   ret <3 x double> %13
; CHECK-NEXT: }

; CHECK: define internal <3 x double> @fwddiffe3alldiv2(double* nocapture readonly %A, <3 x double>* %"A'", i64 %N)
; CHECK-NEXT: entry:
; CHECK-NEXT:   br label %loop

; CHECK: loop:                                             ; preds = %loop, %entry
; CHECK-NEXT:   %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
; CHECK-NEXT:   %0 = phi {{(fast )?}}double [ 0.000000e+00, %entry ], [ %11, %loop ]
; CHECK-NEXT:   %1 = phi {{(fast )?}}double [ 0.000000e+00, %entry ], [ %12, %loop ]
; CHECK-NEXT:   %2 = phi {{(fast )?}}double [ 0.000000e+00, %entry ], [ %13, %loop ]
; CHECK-NEXT:   %reduce = phi double [ 2.000000e+00, %entry ], [ %div, %loop ]
; CHECK-NEXT:   %3 = insertelement <3 x double> undef, double %0, i32 0
; CHECK-NEXT:   %4 = insertelement <3 x double> %3, double %1, i32 1
; CHECK-NEXT:   %5 = insertelement <3 x double> %4, double %2, i32 2
; CHECK-NEXT:   %iv.next = add nuw nsw i64 %iv, 1
; CHECK-NEXT:   %"gep'ipg" = getelementptr inbounds <3 x double>, <3 x double>* %"A'", i64 %iv
; CHECK-NEXT:   %gep = getelementptr inbounds double, double* %A, i64 %iv
; CHECK-NEXT:   %"ld'ipl" = load <3 x double>, <3 x double>* %"gep'ipg", align 8, !tbaa !2
; CHECK-NEXT:   %ld = load double, double* %gep, align 8, !tbaa !2
; CHECK-NEXT:   %div = fdiv double %reduce, %ld
; CHECK-NEXT:   %.splatinsert = insertelement <3 x double> {{(poison|undef)}}, double %reduce, i32 0
; CHECK-NEXT:   %.splat = shufflevector <3 x double> %.splatinsert, <3 x double> {{(poison|undef)}}, <3 x i32> zeroinitializer
; CHECK-NEXT:   %.splatinsert1 = insertelement <3 x double> {{(poison|undef)}}, double %ld, i32 0
; CHECK-NEXT:   %.splat2 = shufflevector <3 x double> %.splatinsert1, <3 x double> {{(poison|undef)}}, <3 x i32> zeroinitializer
; CHECK-NEXT:   %6 = fmul fast <3 x double> %5, %.splat2
; CHECK-NEXT:   %7 = fmul fast <3 x double> %.splat, %"ld'ipl"
; CHECK-NEXT:   %8 = fsub fast <3 x double> %6, %7
; CHECK-NEXT:   %9 = fmul fast double %ld, %ld
; CHECK-NEXT:   %.splatinsert3 = insertelement <3 x double> {{(poison|undef)}}, double %9, i32 0
; CHECK-NEXT:   %.splat4 = shufflevector <3 x double> %.splatinsert3, <3 x double> {{(poison|undef)}}, <3 x i32> zeroinitializer
; CHECK-NEXT:   %10 = fdiv fast <3 x double> %8, %.splat4
; CHECK-NEXT:   %cmp = icmp eq i64 %iv.next, %N
; CHECK-NEXT:   %11 = extractelement <3 x double> %10, i64 0
; CHECK-NEXT:   %12 = extractelement <3 x double> %10, i64 1
; CHECK-NEXT:   %13 = extractelement <3 x double> %10, i64 2
; CHECK-NEXT:   br i1 %cmp, label %end, label %loop

; CHECK: end:                                              ; preds = %loop
; CHECK-NEXT:   ret <3 x double> %10
; CHECK-NEXT: }