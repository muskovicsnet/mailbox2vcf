require 'maildir'

class Mailboxtovcf
  def initialize(maildir_path)
    @maildir_path = maildir_path
    @namepair_data = {}
  end

  def read_maildir
    maildir = Maildir.new(@maildir_path)
    maildir.serializer = Maildir::Serializer::Mail.new

    messages = maildir.list(:cur)
    messages.each do |message|
      save_data(message.data[:from].addrs)
      save_data(message.data[:to].addrs)
    end

    write_to_file(@namepair_data)
  end

  def write_to_file(data_hash)
    open('output.txt', 'w') do |f|
      data_hash.each do |row|
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

if ARGV.size == 1
  dir = ARGV[0]
  dir_cur = dir + '/cur'
  dir_exists = Dir.exists?(dir)
  dir_cur_exists = Dir.exists?(dir_cur)
  if dir_exists
    if dir_cur_exists
      app = Mailboxtovcf.new(dir)
      app.read_maildir
      puts "Output successfully written to: output.txt"
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
  puts "Usage: mailbox2vcf [maildir]"
  exit 1
end
