function rdmap = imrender(labmap, levels_, name)
cmapf = str2func(name); cmap = cmapf(levels_);
rdmap = arrayfun(@(ic)(reshape(cmap(labmap,ic),size(labmap))),1:3,'Uni',0);
rdmap = cat(3,rdmap{:});
end