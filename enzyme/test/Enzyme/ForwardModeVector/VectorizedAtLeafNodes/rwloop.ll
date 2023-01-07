; RUN: %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -enzyme-vectorize-at-leaf-nodes -mem2reg -early-cse -simplifycfg -instsimplify -correlated-propagation -adce -S | FileCheck %s

; ModuleID = '../test/Integration/rwrloop.c'
source_filename = "../test/Integration/rwrloop.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind
declare <3 x double> @__enzyme_fwddiff(i8*, ...)

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@.str = private unnamed_addr constant [16 x i8] c"d_a[%d][%d]=%f\0A\00", align 1
@stderr = external dso_local local_unnamed_addr global %struct._IO_FILE*, align 8
@.str.1 = private unnamed_addr constant [68 x i8] c"Assertion Failed: fabs( [%s = %g] - [%s = %g] ) > %g at %s:%d (%s)\0A\00", align 1
@.str.2 = private unnamed_addr constant [10 x i8] c"d_a[i][j]\00", align 1
@.str.3 = private unnamed_addr constant [15 x i8] c"2. * (i*100+j)\00", align 1
@.str.4 = private unnamed_addr constant [30 x i8] c"../test/Integration/rwrloop.c\00", align 1
@__PRETTY_FUNCTION__.main = private unnamed_addr constant [23 x i8] c"int main(int, char **)\00", align 1

; Function Attrs: norecurse nounwind uwtable
define dso_local double @alldiv(double* noalias nocapture %a, i32* noalias nocapture %N) #0 {
entry:
  %0 = load i32, i32* %N, align 4, !tbaa !2
  %cmp233 = icmp sgt i32 %0, 0
  br label %for.cond1.preheader

for.cond1.preheader:                              ; preds = %for.cond.cleanup3, %entry
  %indvar = phi i64 [ 0, %entry ], [ %indvar.next, %for.cond.cleanup3 ]
  %sum.036 = phi double [ 0.000000e+00, %entry ], [ %sum.1.lcssa, %for.cond.cleanup3 ]
  br i1 %cmp233, label %for.body4.lr.ph, label %for.cond.cleanup3

for.body4.lr.ph:                                  ; preds = %for.cond1.preheader
  %1 = mul nuw nsw i64 %indvar, 10
  %2 = load i32, i32* %N, align 4, !tbaa !2
  %3 = sext i32 %2 to i64
  br label %for.body4

for.body4:                                        ; preds = %for.body4.lr.ph, %for.body4
  %indvars.iv = phi i64 [ 0, %for.body4.lr.ph ], [ %indvars.iv.next, %for.body4 ]
  %sum.134 = phi double [ %sum.036, %for.body4.lr.ph ], [ %add10, %for.body4 ]
  %4 = add nuw nsw i64 %indvars.iv, %1
  %arrayidx = getelementptr inbounds double, double* %a, i64 %4
  %5 = load double, double* %arrayidx, align 8, !tbaa !6
  %mul9 = fmul double %5, %5
  %add10 = fadd double %sum.134, %mul9
  store double 0.000000e+00, double* %arrayidx, align 8, !tbaa !6
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %cmp2 = icmp slt i64 %indvars.iv.next, %3
  br i1 %cmp2, label %for.body4, label %for.cond.cleanup3

for.cond.cleanup3:                                ; preds = %for.body4, %for.cond1.preheader
  %sum.1.lcssa = phi double [ %sum.036, %for.cond1.preheader ], [ %add10, %for.body4 ]
  %indvar.next = add nuw nsw i64 %indvar, 1
  %exitcond = icmp eq i64 %indvar.next, 10
  br i1 %exitcond, label %for.cond.cleanup, label %for.cond1.preheader

for.cond.cleanup:                                 ; preds = %for.cond.cleanup3
  store i32 7, i32* %N, align 4, !tbaa !2
  ret double %sum.1.lcssa
}

define void @main(double* %a, <3 x double>* %da, i32* %N) {
entry:
  %call = call <3 x double> (i8*, ...) @__enzyme_fwddiff(i8* bitcast (double (double*, i32*)* @alldiv to i8*), metadata !"enzyme_width", i64 3, double* nonnull %a, <3 x double>* %da, i32* nonnull %N)
  ret void
}

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #3

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1) #1

; Function Attrs: nounwind
declare dso_local i32 @printf(i8* nocapture readonly, ...) local_unnamed_addr #5

; Function Attrs: nounwind
declare dso_local i32 @fflush(%struct._IO_FILE* nocapture) local_unnamed_addr #5

; Function Attrs: nounwind readnone speculatable
declare double @llvm.fabs.f64(double) #6

; Function Attrs: nounwind
declare dso_local i32 @fprintf(%struct._IO_FILE* nocapture, i8* nocapture readonly, ...) local_unnamed_addr #5

; Function Attrs: noreturn nounwind
declare dso_local void @abort() local_unnamed_addr #7

; Function Attrs: nounwind
declare void @llvm.stackrestore(i8*) #3

attributes #0 = { norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nounwind readnone speculatable }
attributes #7 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { cold }
attributes #9 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 7.0.0 (trunk 336729)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"double", !4, i64 0}
!8 = !{!9, !9, i64 0}
!9 = !{!"any pointer", !4, i64 0}


; CHECK: define internal <3 x double> @fwddiffe3alldiv(double* noalias nocapture %a, <3 x double>* %"a'", i32* noalias nocapture %N)
; CHECK-NEXT: entry:
; CHECK-NEXT:   %0 = load i32, i32* %N, align 4, !tbaa !2
; CHECK-NEXT:   %cmp233 = icmp sgt i32 %0, 0
; CHECK-NEXT:   br label %for.cond1.preheader

; CHECK: for.cond1.preheader:                              ; preds = %for.cond.cleanup3, %entry
; CHECK-NEXT:   %1 = phi {{(fast )?}}double [ 0.000000e+00, %entry ], [ %21, %for.cond.cleanup3 ]
; CHECK-NEXT:   %2 = phi {{(fast )?}}double [ 0.000000e+00, %entry ], [ %22, %for.cond.cleanup3 ]
; CHECK-NEXT:   %3 = phi {{(fast )?}}double [ 0.000000e+00, %entry ], [ %23, %for.cond.cleanup3 ]
; CHECK-NEXT:   %iv = phi i64 [ %iv.next, %for.cond.cleanup3 ], [ 0, %entry ]
; CHECK-NEXT:   %iv.next = add nuw nsw i64 %iv, 1
; CHECK-NEXT:   br i1 %cmp233, label %for.body4.lr.ph, label %for.cond.cleanup3

; CHECK: for.body4.lr.ph:                                  ; preds = %for.cond1.preheader
; CHECK-NEXT:   %4 = mul nuw nsw i64 %iv, 10
; CHECK-NEXT:   %5 = load i32, i32* %N, align 4, !tbaa !2
; CHECK-NEXT:   %6 = sext i32 %5 to i64
; CHECK-NEXT:   br label %for.body4

; CHECK: for.body4:                                        ; preds = %for.body4, %for.body4.lr.ph
; CHECK-NEXT:   %7 = phi {{(fast )?}}double [ %1, %for.body4.lr.ph ], [ %18, %for.body4 ]
; CHECK-NEXT:   %8 = phi {{(fast )?}}double [ %2, %for.body4.lr.ph ], [ %19, %for.body4 ]
; CHECK-NEXT:   %9 = phi {{(fast )?}}double [ %3, %for.body4.lr.ph ], [ %20, %for.body4 ]
; CHECK-NEXT:   %iv1 = phi i64 [ %iv.next2, %for.body4 ], [ 0, %for.body4.lr.ph ]
; CHECK-NEXT:   %10 = insertelement <3 x double> undef, double %7, i32 0
; CHECK-NEXT:   %11 = insertelement <3 x double> %10, double %8, i32 1
; CHECK-NEXT:   %12 = insertelement <3 x double> %11, double %9, i32 2
; CHECK-NEXT:   %iv.next2 = add nuw nsw i64 %iv1, 1
; CHECK-NEXT:   %13 = add nuw nsw i64 %iv1, %4
; CHECK-NEXT:   %"arrayidx'ipg" = getelementptr inbounds <3 x double>, <3 x double>* %"a'", i64 %13
; CHECK-NEXT:   %arrayidx = getelementptr inbounds double, double* %a, i64 %13
; CHECK-NEXT:   %"'ipl" = load <3 x double>, <3 x double>* %"arrayidx'ipg", align 8, !tbaa !6
; CHECK-NEXT:   %14 = load double, double* %arrayidx, align 8, !tbaa !6
; CHECK-NEXT:   %.splatinsert = insertelement <3 x double> {{(poison|undef)}}, double %14, i32 0
; CHECK-NEXT:   %.splat = shufflevector <3 x double> %.splatinsert, <3 x double> {{(poison|undef)}}, <3 x i32> zeroinitializer
; CHECK-NEXT:   %15 = fmul fast <3 x double> %"'ipl", %.splat
; CHECK-NEXT:   %16 = fadd fast <3 x double> %15, %15
; CHECK-NEXT:   %17 = fadd fast <3 x double> %12, %16
; CHECK-NEXT:   store double 0.000000e+00, double* %arrayidx
; CHECK-NEXT:   store <3 x double> zeroinitializer, <3 x double>* %"arrayidx'ipg"
; CHECK-NEXT:   %cmp2 = icmp slt i64 %iv.next2, %6
; CHECK-NEXT:   %18 = extractelement <3 x double> %17, i64 0
; CHECK-NEXT:   %19 = extractelement <3 x double> %17, i64 1
; CHECK-NEXT:   %20 = extractelement <3 x double> %17, i64 2
; CHECK-NEXT:   br i1 %cmp2, label %for.body4, label %for.cond.cleanup3

; CHECK: for.cond.cleanup3:                                ; preds = %for.body4, %for.cond1.preheader
; CHECK-NEXT:   %21 = phi {{(fast )?}}double [ %1, %for.cond1.preheader ], [ %18, %for.body4 ]
; CHECK-NEXT:   %22 = phi {{(fast )?}}double [ %2, %for.cond1.preheader ], [ %19, %for.body4 ]
; CHECK-NEXT:   %23 = phi {{(fast )?}}double [ %3, %for.cond1.preheader ], [ %20, %for.body4 ]
; CHECK-NEXT:   %24 = insertelement <3 x double> undef, double %21, i32 0
; CHECK-NEXT:   %25 = insertelement <3 x double> %24, double %22, i32 1
; CHECK-NEXT:   %26 = insertelement <3 x double> %25, double %23, i32 2
; CHECK-NEXT:   %exitcond = icmp eq i64 %iv.next, 10
; CHECK-NEXT:   br i1 %exitcond, label %for.cond.cleanup, label %for.cond1.preheader

; CHECK: for.cond.cleanup:                                 ; preds = %for.cond.cleanup3
; CHECK-NEXT:   store i32 7, i32* %N, align 4, !tbaa !2
; CHECK-NEXT:   ret <3 x double> %26
; CHECK-NEXT: }