function Character:onCreate()
    
end

function Character:postCreate()
    self.data.x = self.data.x + 200
    self.data.y = self.data.y + 50
end

