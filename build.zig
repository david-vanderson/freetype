const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libmod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const lib = b.addLibrary(.{
        .name = "freetype",
        .root_module = libmod,
    });
    const t = target.result;

    libmod.addCMacro("FT2_BUILD_LIBRARY", "1");
    libmod.addIncludePath(b.path("include"));

    switch (t.os.tag) {
        .windows => {
            libmod.addCSourceFile(.{ .file = b.path("builds/windows/ftsystem.c"), .flags = &.{} });
            libmod.addCSourceFile(.{ .file = b.path("builds/windows/ftdebug.c"), .flags = &.{} });
        },
        else => {
            libmod.addCSourceFile(.{ .file = b.path("src/base/ftsystem.c"), .flags = &.{} });
            libmod.addCSourceFile(.{ .file = b.path("src/base/ftdebug.c"), .flags = &.{} });
        },
    }

    if (t.os.tag.isBSD() or t.os.tag == .linux) {
        libmod.addCMacro("HAVE_UNISTD_H", "1");
        libmod.addCMacro("HAVE_FCNTL_H", "1");
        libmod.addCSourceFile(.{ .file = b.path("builds/unix/ftsystem.c"), .flags = &.{} });
        if (t.os.tag == .macos)
            libmod.addCSourceFile(.{ .file = b.path("src/base/ftmac.c"), .flags = &.{} });
    }
    libmod.addCSourceFiles(.{ .files = freetype_base_sources });

    b.installArtifact(lib);
    lib.installHeadersDirectory(b.path("include/freetype"), "freetype", .{});
    lib.installHeader(b.path("include/ft2build.h"), "ft2build.h");
}

const freetype_base_sources = &[_][]const u8{
    "src/autofit/autofit.c",
    "src/base/ftbase.c",
    "src/base/ftbbox.c",
    "src/base/ftbdf.c",
    "src/base/ftbitmap.c",
    "src/base/ftcid.c",
    "src/base/ftfstype.c",
    "src/base/ftgasp.c",
    "src/base/ftglyph.c",
    "src/base/ftgxval.c",
    "src/base/ftinit.c",
    "src/base/ftmm.c",
    "src/base/ftotval.c",
    "src/base/ftpatent.c",
    "src/base/ftpfr.c",
    "src/base/ftstroke.c",
    "src/base/ftsynth.c",
    "src/base/fttype1.c",
    "src/base/ftwinfnt.c",
    "src/bdf/bdf.c",
    "src/bzip2/ftbzip2.c",
    "src/cache/ftcache.c",
    "src/cff/cff.c",
    "src/cid/type1cid.c",
    "src/gzip/ftgzip.c",
    "src/lzw/ftlzw.c",
    "src/pcf/pcf.c",
    "src/pfr/pfr.c",
    "src/psaux/psaux.c",
    "src/pshinter/pshinter.c",
    "src/psnames/psnames.c",
    "src/raster/raster.c",
    "src/sdf/sdf.c",
    "src/sfnt/sfnt.c",
    "src/smooth/smooth.c",
    "src/svg/svg.c",
    "src/truetype/truetype.c",
    "src/type1/type1.c",
    "src/type42/type42.c",
    "src/winfonts/winfnt.c",
};
