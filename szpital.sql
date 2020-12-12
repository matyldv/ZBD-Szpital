create table Specjalizacje(
	nazwa varchar2(100) primary key);

create table Oddzialy(
	nazwa varchar2(50) primary key,
	opis varchar2(200));

create table Pacjenci(
	imie varchar2(100) not null,
	nazwisko varchar2(100) not null,
	data_urodzenia date not null,
	pesel varchar2(20) primary key,
	ulica varchar2(100) not null,
	miasto varchar2(50) not null,
	kod_pocztowy varchar2(6) not null,
	telefon varchar2(20) not null);

create table Lekarze(
	id_lekarza number(6) primary key,
	imie varchar2(100) not null,
	nazwisko varchar2(100) not null,
	telefon varchar2(20) not null,
	specjalizacja varchar2(100) references Specjalizacje(nazwa),
	oddzial varchar2(50) references Oddzialy(nazwa) not null);
	
create table Pielegniarki(
	id_pielegniarki number(6) primary key,
	imie varchar2(100) not null,
	nazwisko varchar2(100) not null,
	telefon varchar2(20) not null,
	oddzial varchar2(50) references Oddzialy(nazwa) not null);

	
create table Sprzety(
	numer_seryjny varchar2(20) primary key,
	nazwa varchar2(50) not null,
	producent varchar2(50) not null,
	rok_produkcji date not null,
	nazwa_oddzialu varchar2(50) references Oddzialy(nazwa) not null);
	
create table Sale(
	numer number(4) primary key,
	pietro number(2) not null,
	oddzial varchar2(50) references Oddzialy(nazwa) not null);

create table Badania(
	nazwa varchar2(100) primary key,
	cena number(4,2) not null,
	czas_oczekiwania number(2) not null);
	
create table BadaniaPacjentow(
	id_badania number(6) primary key,
	nazwa_badania varchar2(100) references Badania(nazwa) not null,
	pacjent varchar2(20) references Pacjenci(pesel) not null,
	lekarz number(6) references Lekarze(id_lekarza) not null,
	data_badania date not null);
	
create table Wyniki(
	id_wyniku number(6) primary key,
	id_badania references BadaniaPacjentow(id_badania) not null,
	wynik_badania varchar2(100) not null,
	zalecenia varchar2(100));

create table Przyjecia(
	data_przyjecia date,
	lekarz number(6) references Lekarze(id_lekarza),
	pacjent varchar2(20) references Pacjenci(pesel),
	primary key (data_przyjecia, lekarz, pacjent),
	nr_sali number(4) references Sale(numer) not null);