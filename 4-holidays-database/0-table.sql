CREATE TABLE bikesharingcalendar (
    day INTEGER NOT NULL,
    mnth INTEGER NOT NULL,
    yr INTEGER NOT NULL,
    originalyear INTEGER NOT NULL,
    holiday INTEGER NOT NULL,
    weekday INTEGER NOT NULL,
    workingday INTEGER NOT NULL,
    PRIMARY KEY (day, mnth, yr)
);
