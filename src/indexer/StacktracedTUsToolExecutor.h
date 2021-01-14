/* #ifndef LLVM_CLANG_TOOLING_ALLTUSEXECUTION_H
#define LLVM_CLANG_TOOLING_ALLTUSEXECUTION_H */

#include "clang/Tooling/ArgumentsAdjusters.h"
#include "clang/Tooling/Execution.h"

namespace clang {
namespace tooling {

/// Executes given frontend actions on all files/TUs in the compilation
/// database.
class StacktracedTUsToolExecutor : public ToolExecutor {
public:
  static const char *ExecutorName;

  /// Init with \p CompilationDatabase.
  /// This uses \p ThreadCount threads to exececute the actions on all files in
  /// parallel. If \p ThreadCount is 0, this uses `llvm::hardware_concurrency`.
  StacktracedTUsToolExecutor(const CompilationDatabase &Compilations,
                     unsigned ThreadCount,
                     std::shared_ptr<PCHContainerOperations> PCHContainerOps =
                         std::make_shared<PCHContainerOperations>());

  /// Init with \p CommonOptionsParser. This is expected to be used by
  /// `createExecutorFromCommandLineArgs` based on commandline options.
  ///
  /// The executor takes ownership of \p Options.
  StacktracedTUsToolExecutor(CommonOptionsParser Options, unsigned ThreadCount,
                     std::shared_ptr<PCHContainerOperations> PCHContainerOps =
                         std::make_shared<PCHContainerOperations>());

  StringRef getExecutorName() const override { return ExecutorName; }

  using ToolExecutor::execute;

  llvm::Error
  execute(llvm::ArrayRef<
          std::pair<std::unique_ptr<FrontendActionFactory>, ArgumentsAdjuster>>
              Actions) override;

  ExecutionContext *getExecutionContext() override { return &Context; };

  ToolResults *getToolResults() override { return Results.get(); }

  void mapVirtualFile(StringRef FilePath, StringRef Content) override {
    OverlayFiles[FilePath] = Content;
  }

private:
  // Used to store the parser when the executor is initialized with parser.
  llvm::Optional<CommonOptionsParser> OptionsParser;
  const CompilationDatabase &Compilations;
  std::unique_ptr<ToolResults> Results;
  ExecutionContext Context;
  llvm::StringMap<std::string> OverlayFiles;
  unsigned ThreadCount;
};

extern llvm::cl::opt<unsigned> ExecutorConcurrency;
extern llvm::cl::opt<std::string> Filter;

} // end namespace tooling
} // end namespace clang

//#endif // LLVM_CLANG_TOOLING_ALLTUSEXECUTION_H