#! /usr/bin/env ruby
# Runs all shadow timing tests for SU13 and SU14 producing a set of csv files
# for the results.  Reads all input files from a "Models" subdirectory and 
# runs the test 3x and average the results.

if RUBY_PLATFORM.downcase.include? 'mingw32'
  @platform = 'win'    
  exe13 = 'C:\Program Files (x86)\SketchUp\SketchUp 2013\SketchUp.exe'
  exe14 = 'C:\Program Files (x86)\SketchUp\SketchUp 2014\SketchUp.exe'
  none = '.\no_shadows.rb'
  full = '.\full_shadows.rb'
  grnd = '.\ground_shadows.rb'
  both = '.\ground_and_full_shadows.rb'
	
elsif RUBY_PLATFORM.downcase.include? 'darwin'
  @platform = 'mac'
  exe13 = "'/Applications/SketchUp 2013/SketchUp.app'"
  exe14 = "'/Applications/SketchUp 2014/SketchUp.app'" 
  none = File.expand_path(File.dirname(__FILE__)+'/no_shadows.rb')
  full = File.expand_path(File.dirname(__FILE__)+'/full_shadows.rb')
  grnd = File.expand_path(File.dirname(__FILE__)+'/ground_shadows.rb')
  both = File.expand_path(File.dirname(__FILE__)+'/ground_and_full_shadows.rb')	
end

models = 'Models'
runs = 3

prefix_1 = '13_'
prefix_2 = '14_'

none_out = 'timing_no_shadows.csv'
grnd_out = 'timing_ground_shadows.csv'
full_out = 'timing_full_shadows.csv'
both_out = 'timing_ground_and_full_shadows.csv'

def run_timing_tests(exe, model_directory, results_file = "", script = "", runs = 1)

  script_file_path = File.expand_path(File.dirname(__FILE__))
  model_dir_path = File.join(script_file_path, model_directory)
  files = Dir.glob("#{model_dir_path}/*.skp")
  
  script_cmd = ''
  script_base = "no_script"  
    
  if (@platform == 'win' && script != "")
     script_cmd = ' /RubyStartup ' + script + ' '
     script_base = File.basename(script, ".rb")
     output = './timing.txt'
     timing = '/timing ' + output + ' '
     
  elsif (@platform == 'mac' && script != "")
     script_cmd = ' -RubyStartup ' + script + ' '
     script_base = File.basename(script, ".rb")
     output = script_file_path + '/timing.txt'
     timing = '-timing ' + output + ' '
  end 
 
  # We use the output file to determine if the test succeeded.  If not, we
  # exit.  So just click on the close button to terminate the tests.

  if (File::exists?(output))
    File.delete(output)
  end  
  
  if (results_file == "")
    results_file = "timing.csv"
  end 

  results_file = File.join(script_file_path, 'Results', results_file)
  out_file = File.new(results_file, 'w')
  out_file.write("File Name,File Size,Runs,Total Time,Avg FPS\n")

  all_tests_time = 0
  all_tests_frames = 0

  case  
     when @platform == 'win'
      files.each do |current_file|
        cmd =  '"' + exe + '"' + script_cmd + timing + current_file
        
        puts "cmd = " + cmd

        i = 0
        total_time = 0
        total_frames = 0

        while i < runs do
          system(cmd)
          
          # NOTE: the timing.txt file has the following format
          # total frames, total time(sec),seconds per frame ,frame per seconds
          if (!File::exists?(output))
            puts "Exiting early"
            exit!
          end

          f = File.open(output)
          data = f.readlines().first
          f.close
          File.delete(output)

          parts = data.split(',')

          size = File.size(current_file)/1024
          name = File.basename(current_file)
          frames = parts[0]
          time = parts[1]
          spf = parts[2]
          fps = parts[3]

          total_time += time.to_f
          total_frames += frames.to_i

          i += 1
        end

        size = File.size(current_file)/1024
        name = File.basename(current_file)
        avg_fps = total_frames / total_time
        out_file.write("#{name},#{size},#{runs},#{total_time},#{avg_fps}\n")
        out_file.flush

        all_tests_time += total_time
        all_tests_frames += total_frames
      end
    
    else
      files.each do |current_file|
        cmd =  "open " + "-a " + exe + " --args " + current_file + script_cmd + timing
        puts "cmd = " + cmd

        i = 0
        run_number = 1
        total_time = 0
        total_frames = 0

        while i < runs do

          system(cmd)
          puts "Run number " + run_number.to_s

          # NOTE: the timing.txt file has the following format
          # total frames, total time(sec),seconds per frame ,frame per seconds
          
          counter = 0
          while not FileTest.exist?(output)
            sleep 5
            counter += 5
            puts "..."
            #break if counter > 150
            if counter > 150
              File.open output ,'w' do |f|
                f.puts '0,0,0,0'
              end
              break
            end
          end
          #if (!File::exists?(output))
          #  puts "Exiting early"
          #  exit!
          #end

          f = File.open(output)
          data = f.readlines().first
          puts data
          f.close
          File.delete(output)

          parts = data.split(',')
      
          size = File.size(current_file)/1024
          name = File.basename(current_file)
          frames = parts[0]
          time = parts[1]
          spf = parts[2]
          fps = parts[3]
      
          total_time += time.to_f
          total_frames += frames.to_i
      
          i += 1
          run_number += 1

        end

        size = File.size(current_file)/1024
        name = File.basename(current_file)
        avg_fps = total_frames / total_time
        out_file.write("#{name},#{size},#{runs},#{total_time},#{avg_fps}\n")
        out_file.flush

        all_tests_time += total_time
        all_tests_frames += total_frames
      end		
  end

  all_tests_fps = all_tests_frames / all_tests_time
  out_file.write("All Tests: Time=#{all_tests_time} FPS=#{all_tests_fps}\n")
  out_file.close
end

run_timing_tests(exe13, models, prefix_1 + none_out, none, runs)
run_timing_tests(exe13, models, prefix_1 + grnd_out, grnd, runs)
run_timing_tests(exe13, models, prefix_1 + full_out, full, runs)
run_timing_tests(exe13, models, prefix_1 + both_out, both, runs)

run_timing_tests(exe14, models, prefix_2 + none_out, none, runs)
run_timing_tests(exe14, models, prefix_2 + grnd_out, grnd, runs)
run_timing_tests(exe14, models, prefix_2 + full_out, full, runs)
run_timing_tests(exe14, models, prefix_2 + both_out, both, runs)
