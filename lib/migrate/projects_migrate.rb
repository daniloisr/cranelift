class Migrate::ProjectsMigrate < Migrate::Base
  class FakeRepository < ::ActiveRecord::Base
    self.table_name = 'repositories'
  end

  def migrate
    puts "Migrando projetos..."

    regs = mysql.query('select * from projetos')
    regs.each do |reg|

      copy_repository_from_php(reg['alias'])

      pj = ::Project.create :name => reg['alias']
      debug_obj(pj)

      repo = FakeRepository.create :name => reg['alias'],
        :url => reg['nome'],
        :enable_autoupdate => reg['autoupdate'],
        :login => reg['co_login'],
        :password => reg['co_password'],
        :project_id => pj.id

    end
  end

  def copy_repository_from_php(repository)
    origin = File.join(config.php_projects_path, repository)
    destiny = Rails.root.join('repositories', repository)

    FileUtils.mkdir destiny
    FileUtils.cp_r Dir[origin], File.join(destiny, ''), :verbose => true
  end

  def create_fake_folders
    puts "Criando pastas fakes para desenvolvimento..."

    regs = mysql.query('select * from projetos')
    regs.each do |r|
      name = r['alias']
      FileUtils.mkpath File.join(config.php_projects_path, name, name)
    end
  end

end
