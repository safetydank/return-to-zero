require 'rake/clean'

$EXE = "null.exe"

if ENV['GDC']
    DD = "gdc"
    OFLAG = "-o "
#    DFLAGS = "-pg"
    DFLAGS = "-g -I c:\\mingw\\include\\d\\3.4.5 -O2"
    LDFLAGS = "-L lib -lgphobos -luuid -lole32 -ladvapi32 -lkernel32 -luser32 -lgdi32"
    OBJEXT = "o"
    $EXE = $EXE.split('.').insert(1, 'mingw').join('.')
else
    DD = "dmd.exe"
    OFLAG = "-of"
    LDFLAGS = "uuid.lib"
#    DFLAGS = "-unittest"
    DFLAGS = ""
    ENV['LIB'] = "\dmd\lib;\dm\lib;lib"
    OBJEXT = "obj"
end

DOXYGEN = "doxygen"

SRC = FileList['**/*.d']
OBJ = SRC.map { |f| f.ext(OBJEXT) }

CLEAN.exclude('core')
CLEAN.include(FileList["**/*.#{OBJEXT}"])
CLOBBER.include("**/#{$EXE}", "**/*.map", "**/*.log", "doc/**/*")

DEPENDENCIES = {}

def read_dependencies(filename)
    File.open(filename) do |f|
        while line = f.gets
            if line =~ /import\s+([\w\.]*)\s*;/
                depsrc = $1.gsub('.', File::SEPARATOR) << ".d"
                DEPENDENCIES[filename] = {} unless DEPENDENCIES[filename]
                DEPENDENCIES[filename][depsrc] ||= true if SRC.include?(depsrc) \
                                                       and SRC.include?(filename)
            end
        end
    end
end

# Calculate dependencies between all D source files
SRC.each { |filename| read_dependencies(filename) }

SRC.each do |srcfile|
    objfile = srcfile.ext(OBJEXT)
    deps = [srcfile] 
    (deps << DEPENDENCIES[srcfile].keys).flatten! if DEPENDENCIES[srcfile]

    file objfile => deps do
        sh "#{DD} -c #{DFLAGS} #{OFLAG}#{objfile} #{srcfile}"
    end 
end

task :default => ["main"]

multitask "main" => OBJ do
    sh "#{DD} #{OFLAG}#{$EXE} #{OBJ} #{LDFLAGS}"
    FileUtils.mv "#{$EXE}","bin"
end

task "run" => ["main"] do
    FileUtils.cp "scripts/config.lua", "bin"
    cd "bin"
    exec $EXE
end

task "doc" do
    sh "#{DOXYGEN}"    
end
