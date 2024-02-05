const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .x86_64,
            .os_tag = .windows,
            .abi = .gnu,
        },
    });
    const optimize = b.standardOptimizeOption(.{});

    const win_pthreads_source = b.dependency("winpthreads_source", .{
        .target = target,
        .optimize = optimize,
    });

    const cflags: []const []const u8 = &[_][]const u8{
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wconversion",
        "-Wsign-conversion",
    };

    const win_pthreads = b.addStaticLibrary(.{
        .name = "winpthreads",
        .optimize = optimize,
        .target = target,
    });
    win_pthreads.defineCMacro("__USE_MINGW_ANSI_STDIO", "1");
    win_pthreads.addIncludePath(win_pthreads_source.path("mingw-w64-libraries/winpthreads/include"));
    win_pthreads.addIncludePath(win_pthreads_source.path("mingw-w64-libraries/winpthreads/src"));
    win_pthreads.linkLibC();
    win_pthreads.addCSourceFiles(.{
        .flags = cflags,
        .files = &.{
            "mingw-w64-libraries/winpthreads/src/nanosleep.c",
            "mingw-w64-libraries/winpthreads/src/cond.c",
            "mingw-w64-libraries/winpthreads/src/barrier.c",
            "mingw-w64-libraries/winpthreads/src/misc.c",
            "mingw-w64-libraries/winpthreads/src/clock.c",
            "mingw-w64-libraries/winpthreads/src/libgcc/dll_math.c",
            "mingw-w64-libraries/winpthreads/src/spinlock.c",
            "mingw-w64-libraries/winpthreads/src/thread.c",
            "mingw-w64-libraries/winpthreads/src/mutex.c",
            "mingw-w64-libraries/winpthreads/src/sem.c",
            "mingw-w64-libraries/winpthreads/src/sched.c",
            "mingw-w64-libraries/winpthreads/src/ref.c",
            "mingw-w64-libraries/winpthreads/src/rwlock.c",
        },
        .dependency = win_pthreads_source,
    });

    b.installArtifact(win_pthreads);
    b.installDirectory(.{
        .source_dir = win_pthreads_source.path("mingw-w64-libraries/winpthreads/include"),
        .install_dir = .header,
        .install_subdir = "",
    });
}
