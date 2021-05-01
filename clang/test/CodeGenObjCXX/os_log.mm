// RUN: %clang_cc1 %s -emit-llvm -o - -triple x86_64-darwin-apple -fobjc-arc \
// RUN:   -fexceptions -fcxx-exceptions | FileCheck %s

// Check that no EH cleanup is emitted around the call to __os_log_helper.
namespace no_eh_cleanup {
  void release(int *lock);

  // CHECK-LABEL: define {{.*}} @_ZN13no_eh_cleanup3logERiPcS1_(
  void log(int &i, char *data, char *buf) {
      int lock __attribute__((cleanup(release)));
      __builtin_os_log_format(buf, "%d %{public}s", i, data);
  }

  // An `invoke` of a `nounwind` callee is simplified to a direct
  // call by an optimization in llvm. Just check that we emit `nounwind`.
  // CHECK: define {{.*}} @__os_log_helper_1_2_2_4_0_8_34({{.*}} [[NUW:#[0-9]+]]
}

// CHECK: attributes [[NUW]] = { {{.*}}nounwind