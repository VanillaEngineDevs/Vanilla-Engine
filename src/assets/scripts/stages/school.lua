function Stage:build()
    print(weeks:getSongName():lower():strip() == "roses")
    if weeks:getSongName():lower():strip() == "roses" then
        get("freaks"):setSuffix("-scared")
        print("Applied scared suffix to freaks character for Roses song.")
    else
        get("freaks"):setSuffix("")
    end
end