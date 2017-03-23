module Upstorm

  class Downloader
    include Upstorm

    # download url we need to snatch
    @download_url = "https://download-cf.jetbrains.com/webide/PhpStorm-[[VERSION]].tar.gz"
    @download_filename = "/tmp/phpstorm-[[VERSION]].tar.gz"

    # default download path
    @download_path = ""
    @default_download_path = "/opt/phpstorm"

    def initialize
      @download_path = @default_download_path
    end

    def run
      # setup defaults
      downloaded = false
      app_running = true
      download_path_correct = false

      # lets make sure we have the correct download path
      while !download_path_correct
        # todo: get download path
        path = get_user_input("Save location correct? [#{@download_path}] [type: y or new location]: ")

        # quit application
        if quit(path)
          puts "Exiting Application"
          app_running = false
          break
        end

        # accept download path
        if accept(path)
          break
        end

        # reset if necessary
        if reset_default_path(path)
          path = @default_download_path
        end
        
        # save download path
        @download_path = path
      end

      # lets attempt to install a version
      version = ""
      while !downloaded && app_running
        # get install version from user
        input = get_user_input()
        
        # quit application
        if quit(input)
          puts "Exiting Application!"
          app_running = false
          break
        end

        # set version if version is empty or we're resetting the value
        version = input if version.empty? || !input.empty?

        # don't continue if version wasn't set
        next if version.empty?

        # parsed url obviously lol
        url = parse_url(@download_url, version)

        # get filename
        filename = @download_filename.gsub("[[VERSION]]", version)

        # attempt to download file
        quit_app = false
        if url_response(url, 200, "binary/octet-stream")
          quit_app = download(url, filename, version)
        else
          puts "Version you're trying to download doesn't return a valid response"
        end

        # exit app
        if quit_app
          app_running = false
        end

      end
    end

    # lets attempt to download & extract the contents then move them
    def download(url, filename, version)
      puts "Attempting to download source"

      if download_from_url(filename, url)
        puts "Source was downloaded successfully!"

        extract_and_move_source(filename, version)
      else
        puts "There was a problem downloading the source code"
        false
      end
    end

    # lets extract and move the contents of the tar to our destination
    def extract_and_move_source(filename : String, version : String)
      puts "Attempting to extract data"

      folder_name = ""
      found_folder = false

      # read the first level of contents from the tar file so we can get the folder name we need to extract
      command = "tar --exclude=\"*/*/*\" -tf #{filename}"
      process = Process.new(command, shell: true, input: true, output: nil, error: true)

      # if there isn't a sub folder then do nothing
      contents = process.output.gets_to_end
      contents.each_line do |line|
        # i loop through the first level of content to get the files inside
        # and assign them to an array so we can attempt to get the folder we need to extract
        pieces = [] of String
        line.split("/"){ |p| pieces << p }
        if !pieces[0].nil?
          folder_name = pieces[0]
          found_folder = true
        end
        break
      end

      # if all goes well and we got the folder name to extract we do just that
      # then move the contents to the folder destination
      if found_folder
        puts "Extracting folder & Moving it to #{@download_path}"
        # untar folder
        system("tar -xvzf #{filename}")

        # remove save folder
        system("rm -rf #{@download_path}")

        # move folder
        system("mv #{folder_name} #{@download_path}")

        # delete old tar
        system("rm -rf #{filename}")

        puts nil
        puts "Completed download of PhpStorm version #{version}"
        true
      else
        puts "We couldn't find the folder that we needed to extract"
        false
      end

    end

    # download file from the url to our destination
    def download_from_url(filename : String, url : String)
      response = HTTP::Client.get url
      File.open(filename, "w+") do |file|
        file.write(response.body.to_slice)
        file.close
      end

      File.exists?(filename)
    end

    # used to check if the user accepted our question
    def accept(str : String)
      if str == "y" || str == "yes"
        true
      else
        false
      end
    end

    # used to check if the user wants to quit the app
    def quit(str : String)
      if str == "q" || str == "quit"
        true
      else
        false
      end
    end

    # used to check if the user wants to reset the default path
    def reset_default_path(str : String)
      if str == "reset"
        true
      else
        false
      end
    end
  end
end