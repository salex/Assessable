# puts "Start Export"
# filepath = Rails.root.join("db","silly.yaml")
# assessment = Assessable::Assessment.find(9)
# yaml = assessment.export.to_yaml
# File.open(filepath,'w') {|f| f.write(yaml)}
# puts "Wrote Silly Test"
# 
# filepath = Rails.root.join("db","silly.yaml")
# hash = YAML.load(File.read(filepath)
# Assessable::Assessment.import_hash(hash)