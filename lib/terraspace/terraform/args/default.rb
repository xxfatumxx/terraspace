module Terraspace::Terraform::Args
  class Default
    def initialize(name, options={})
      @name, @options = name, options
      @quiet = @options[:quiet].nil? ? true : @options[:quiet]
    end

    def args
      if %w[init apply destroy plan output].include?(@name)
        meth = "#{@name}_args"
        send(meth)
      else
        []
      end
    end

    def apply_args
      args = auto_approve_arg
      var_files = @options[:var_files]
      if var_files
        args << var_files.map { |f| "-var-file #{Dir.pwd}/#{f}" }.join(' ')
      end
      args
    end

    def init_args
      args = "-get"
      if @quiet && !ENV['TS_INIT_LOUD']
        out_path = "#{Terraspace.tmp_root}/out/terraform-init.out"
        FileUtils.mkdir_p(File.dirname(out_path))
        args << " > #{out_path}"
      end
      [args]
    end

    def plan_args
      args = []
      args << "-out #{expanded_out}" if @options[:out]
      args
    end

    def output_args
      args = []
      args << "-json" if @options[:format] == "json"
      args << "> #{expanded_out}" if @options[:out]
      args
    end

    def expanded_out
      out = @options[:out]
      out.starts_with?('/') ? out : "#{Dir.pwd}/#{out}"
    end

    def destroy_args
      auto_approve_arg
    end

    def auto_approve_arg
      @options[:yes] ? ["-auto-approve"] : []
    end
  end
end
