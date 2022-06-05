dataPath = [cd '\RadarData\'];

path1 = [dataPath 'train_x.csv'];
csvwrite(path1, train_x)

path2 = [dataPath 'train_y.csv'];
csvwrite(path2, train_y)

path3 = [dataPath 'test_x.csv'];
csvwrite(path3, test_x)

path4 = [dataPath 'test_y.csv'];
csvwrite(path4, test_y)