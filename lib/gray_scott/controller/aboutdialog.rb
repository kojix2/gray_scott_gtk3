# frozen_string_literal: true

module GrayScott
  class Controller
    class AboutDialog
      def initialize(resource_dir)
        Gtk::AboutDialog.new.tap do |d|
          d.program_name = 'Gray-Scott'
          d.comments = 'Reaction diffusion system'
          d.logo = GdkPixbuf::Pixbuf.new(file: File.join(resource_dir, 'about_icon.png'))
          d.copyright = 'Copyright (C) kojix2'
          d.authors = ['kojix2']
          d.version = GrayScott::VERSION
          d.website = 'https://github.com/kojix2/gray-scott'
          d.website_label = 'Github kojix2/gray-scott'
          d.run
          d.destroy
        end
      end
    end
  end
end
