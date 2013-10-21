

case node["platform_family"]
when "debian"
  apt_repository "cloudera" do
    uri node['bcpc']['repos']['cloudera']
    distribution node['lsb']['codename'] + '-cdh4'
    components ["contrib"]
    arch "amd64"
    key "cloudera-archive.key"
  end

  %w{hadoop hbase hive oozie pig zookeeper}.each do |w|
    directory "/etc/#{w}/conf.bcpc" do
      owner "root"
      group "root"
      mode 00755
      action :create
      recursive true
    end

    bash "update-#{w}-conf-alternatives" do
      code %Q{
       update-alternatives --install /etc/#{w}/conf #{w}-conf /etc/#{w}/conf.bcpc 50
       update-alternatives --set #{w}-conf /etc/#{w}/conf.bcpc
      }
    end
  end

when "rhel"
  ""
  # do things on RHEL platforms (redhat, centos, scientific, etc)
end


%w{capacity-scheduler.xml
   container-executor.cfg
   core-site.xml
   hadoop-metrics2.properties
   hadoop-metrics.properties
   hadoop-policy.xml
   hdfs-site.xml
   log4j.properties
   mapred-site.xml
   slaves
   ssl-client.xml
   ssl-server.xml
   yarn-site.xml
  }.each do |t|
     template "/etc/hadoop/conf/#{t}" do
       source "hdp_#{t}.erb"
       mode 0644
       variables(:hh_hosts => get_hadoop_heads , :quorum_hosts => get_quorum_hosts)
     end
   end

   %w{yarn-env.sh
 hadoop-env.sh}.each do |t|
     template "/etc/hadoop/conf/#{t}" do
       source "hdp_#{t}.erb"
       mode 0755
       variables(:hh_hosts => get_hadoop_heads , :quorum_hosts => get_quorum_hosts)
     end
   end

   %w{zoo.cfg
      log4j.properties
      configuration.xsl
     }.each do |t|
     template "/etc/zookeeper/conf/#{t}" do
       source "zk_#{t}.erb"
       mode 0755
       variables(:hh_hosts => get_hadoop_heads , :quorum_hosts => get_quorum_hosts)
     end
   end

package "openjdk-7-jdk" do
  action :upgrade
end

package "zookeeper" do
  action :upgrade
end
