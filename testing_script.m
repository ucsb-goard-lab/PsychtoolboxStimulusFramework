s = Stimulus();

s.initialize();
s.startTimer();
s.drawBlank(1)

s.getTime();


%s.drawDriftingGrating(2);

load('C:\Users\sit\Dropbox\StimulusPresentation\NaturalScenes\MovieDatabase\antelopes.mat')
s.drawMovie(10, antelopes)
s.cleanUp();


temp = rand(100);
temp2 = rand(100);

stimdat = StimDataLogger(temp, temp2);