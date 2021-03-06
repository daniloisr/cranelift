module Migrate
  class UsersMigrate < Migrate::Base
    def migrate
      puts "Migrando usuarios..."

      users = mysql.query('select * from user')
      users.each do |user|
        obj = ::User.create do |u|
          u.login      = user['login']
          u.password   = u.password_confirmation = (0...8).map{65.+(rand(25)).chr}.join
          u.admin      = user['admin']
          u.role_id    = ::Role.find_by_name(role_name(user['id_role'])).id
          u.ip_block   = user['noipblock'] == 1
          u.name       = user['name']
          u.email      = user['email']
          u.active     = user['actived']   == 1
          u.login_type = user['tipo']
        end
        debug_obj(obj)
      end
    end

    def role_name(id)
      reg = mysql.query("select name from role where id = #{id}")
      return reg.first['name']
    end
  end
end
