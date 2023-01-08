; RUN: %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -enzyme-vectorize-at-leaf-nodes -O3 -S | FileCheck %s

; Function Attrs: nounwind
declare <2 x double> @__enzyme_fwddiff(double (double)*, ...)

; Function Attrs: nounwind readnone uwtable
define double @tester(double %x) {
entry:
  %0 = tail call fast double @llvm.cos.f64(double %x)
  ret double %0
}

define <2 x double> @test_derivative(double %x) {
entry:
  %0 = tail call <2 x double> (double (double)*, ...) @__enzyme_fwddiff(double (double)* nonnull @tester, metadata !"enzyme_width", i64 2, double %x, <2 x double> <double 0.000000e+00, double 1.000000e+00>)
  ret <2 x double> %0
}

; Function Attrs: nounwind readnone speculatable
declare double @llvm.cos.f64(double)


; CHECK: define <2 x double> @test_derivative(double %x)
; CHECK-NEXT: entry:
; CHECK-NEXT:   %0 = tail call fast double @llvm.sin.f64(double %x)
; CHECK-NEXT:   %1 = {{(fsub fast double -0.000000e\+00,|fneg fast double)}} %0
; CHECK-NEXT:   %.splatinsert.i = insertelement <2 x double> {{(poison|undef)}}, double %1, {{(i32|i64)}} 0
; CHECK-NEXT:   %.splat.i = shufflevector <2 x double> %.splatinsert.i, <2 x double> {{(poison|undef)}}, <2 x i32> zeroinitializer
; CHECK-NEXT:   %2 = fmul fast <2 x double> %.splat.i, <double 0.000000e+00, double 1.000000e+00>
; CHECK-NEXT:   ret <2 x double> %2
; CHECK-NEXT: }