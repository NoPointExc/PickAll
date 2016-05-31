#! /usr/bin/env ruby

# 7e3c76fd99cfb0c2f26b62b125524ffcf9377b84
# error:
require 'fileutils'
require 'tempfile'
require 'optparse'

#id: int
def fetch(id)
        is_ok=true
        print "git fetch https://android.googlesource.com/kernel/common refs/changes/#{(id%100).to_s}/#{id.to_s}/1 && git cherry-pick FETCH_HEAD \n"
        is_ok=system("git fetch https://android.googlesource.com/kernel/common refs/changes/#{(id%100).to_s}/#{id.to_s}/1 && git cherry-pick FETCH_HEAD")
        return is_ok
end

#pwd: string
def pick_all(pth)
        rst=1
        count=0
        while rst>0 do
                rst=pick(pth)
                count+=1
        end
        if rst==0
                print "All #{count} patches cherry-picked. \n"
        else
                print "#{count} patches cherry-picked, stop at #{-id}. \n"
        end
end

#pth: string
def pick(pth)
        if !File.file? pth
                print "[ERROR]: #{pth} not found!"
                return -1
        end
        file=File.open(pth,"r")
        tmp_file=File.new("id.tmp","w")

        id=-1

        file.each_line do |line|
                if !line.start_with?("*") && id==-1
                        id=line.to_i
                        line="*"+line
                end
                tmp_file.puts line
        end

        #reach the end of file
        if id==-1
                return 0
        end

        is_ok=fetch(id)
        FileUtils.mv tmp_file , file
        tmp_file.close
        file.close
        rst= is_ok ? id : -id
        return rst
end


def clean_sort(pth)
        file=File.open pth , "r"
        tmp_file=File.new "id.tmp", "w"
        ids=[]

        file.each_line do |line|
                while line.start_with?("*")
                        line=line[1,line.length]
                end
                ids.push line.to_i
        end

        ids.sort!

        for id in ids
                tmp_file.puts id
        end

        FileUtils.mv tmp_file, file
        tmp_file.close
        file.close
        print "#{ids.length} ids in file cleaned and sorted \n"
end

pth="patchs.txt"
#pick_all("patchs.txt")
#clean_sort(pth)

#parse options
options={}

OptionParser.new do |opt|

        opt.banner = "Usage: pick_all.rb [options]"

        opt.on("-a","--[no-]all","cherry-pick all") do |a|
                options[:all] = a
        end

        opt.on("-c","--[no-]clean", "clean and sort id file") do |c|
                options[:clean] = c
        end


        #opt.on("-s",String, "cherry-pick [id]") do |id|
        #       options[:select] = id
        #end

        #opt.on("-f", String, "cherry-pick from [file]") do |file|
        #       options[:pth] = file
        #end
end.parse!

if options[:clean]
        clean_sort(pth)
end

if options[:all]
        pick_all(pth)
end