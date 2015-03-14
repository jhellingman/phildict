

CREATE TABLE calderon
(
   english varchar(254),
   grammar varchar(16),
   phonetic varchar(254),
   spanish varchar(254),
   tagalog varchar(254),

   KEY english (english),
   KEY phonetic (phonetic),
   KEY spanish (spanish),
   KEY tagalog (tagalog)
);
