require 'maildir'

class Mailboxtovcf
  def initialize(maildir_path)
    @maildir_path = maildir_path
    @namepair_data = {}
  end

  def read_maildir(subdir)
    maildir = Maildir.new(@maildir_path)
    maildir.serializer = Maildir::Serializer::Mail.new

    messages = maildir.list(subdir)
    messages.each do |message|
      if (message.data[:from].class == Mail::Field && message.data[:to].class == Mail::Field)
        save_data(message.data[:from].addrs) unless message.data[:from].nil?
        save_data(message.data[:to].addrs) unless message.data[:to].nil?
      end
    end
  end

  def write_to_file(output)
    open(output, 'w') do |f|
      @namepair_data.each do |row|
        f.puts render_vcard(row[0], row[1])
      end
    end
  end

  def save_data(addresses)
    addresses.each do |address|
      name = address.display_name
      address = address.address
      name = address if(name == '' || name == nil)
      unless @namepair_data.keys.include?(name)
        @namepair_data[name] = address
        print '.'
      end
    end
  end

  def render_vcard(name, email)
    from_template(name, email)
  end

  def from_template(name, email)
"""BEGIN:VCARD
VERSION:3.0
FN:#{name}
EMAIL;TYPE=HOME:#{email}
END:VCARD
"""    
  end
end

if ARGV.size >= 3
  dir = ARGV[0]
  output = ARGV[1]
  subdirs = ARGV[2, 99999]
  dir_cur = dir + '/cur'
  dir_exists = Dir.exists?(dir)
  dir_cur_exists = Dir.exists?(dir_cur)
  if dir_exists
    if dir_cur_exists
      app = Mailboxtovcf.new(dir)
      subdirs.each do |subdir|
        app.read_maildir(subdir)
      end
      app.write_to_file(output)
      puts ''
      puts "Output successfully written to: #{output}"
      exit 0
    else
      puts "Directory does not exists: #{dir_cur}"
      exit 1
    end
  else
    puts "Directory does not exists: #{dir}"
    exit 1
  end
else
  puts "Usage: mailbox2vcf [maildir] [outputfile] [maildir_subdirs]"
  exit 1
end
