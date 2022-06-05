dataPath = [cd '\RadarData\'];

path1 = [dataPath 'train_x.csv'];
csvwrite(path1, train_x)
path3 = [dataPath 'test_x.csv'];
csvwrite(path3, test_x)
    
for i = 1:3
    path2 = [dataPath 'train_y' num2str(i) '.csv'];
    csvwrite(path2, train_y{i})
    path4 = [dataPath 'test_y' num2str(i) '.csv'];
    csvwrite(path4, test_y{i})
end