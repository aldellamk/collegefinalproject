%% Algoritma Fuzzy Time Series Qiang Song & Brad S. Chissom dengan Partisi Interval menggunakan Fuzzy C-Means Clustering 
%% Pemanggilan Data
clc;clear all;close all;
format shortG
data = load('datahighwaskitajan.txt');
%% Membentuk Universe of Discourse
disp('Membentuk Universe of Discourse')
d_min = min(data);d_max = max(data);
disp(['Data minimum: ' num2str(d_min) '   Data maksimum: ' num2str(d_max)]);
d1=input('D1= ')
d2=input('D2= ')
U =[d_min-d1 d_max+d2]
%% Pengklasteran dengan Fuzzy C-Means Clustering
k=input('Masukkan jumlah cluster yang diinginkan: ')
plot(data(:,1))
[center,u,objFcn]=fcm(data,k);
plot(objFcn);
maxu=max(u);
for i=1:k
    disp(['Anggota cluster ke-' num2str(i)])
    data(find(u(i,:)==maxu));
    disp(num2str(sort(data(find(u(i,:)==maxu)))))
end
%% Menampilkan Partisi Interval
sortcenter=sort(center)
MU(1,1)=d_min-d1;
MU(k+1,2)=d_max+d2;
for i=1:k
    MU(i+1,1)=sortcenter(i);
    MU(i,2)=sortcenter(i);
end
disp('Subinterval yang terbentuk:');
for i=1:k+1
    nilaitengah(i)=(MU(i,1)+MU(i,2))/2;
    disp(['U' num2str(i) ':    [' num2str(MU(i,1)) ',' num2str(MU(i,2)) '] -- nilai tengah: ' num2str(nilaitengah(i))]);
end

%% Fuzzifikasi
disp('Tabel Hasil Fuzzifikasi');
for j=1:length(data)
for i=1:k+1
        kiri = MU(i,1);
        kanan = MU(i,2);
if data(j)>= kiri && data(j)<= kanan            
            fuzzifikasi(j) = i;
            disp([num2str(j) '.  ' num2str(data(j)) ': A' num2str(fuzzifikasi(j))])
break;
end
end
end
%% Fuzzy Logical Relationship (FLR)
flr=[fuzzifikasi(1:end-1)',fuzzifikasi(2:end)'];
disp('Tabel Fuzzy Logic Relationship (FLR)');
for i=1:length(flr)
    disp([num2str(i) '.  ' num2str(data(i)) ': A' num2str(flr(i,1)) '-> A' num2str(flr(i,2))]);
end
%% Membuat Matriks Markov Chain R
for i=1:k+1
for l=1:k+1
        MF(i,l)=length(find(fuzzifikasi(1:end-1)==i));
        MFLR(i,l)=length(find(flr(:,1)==i&flr(:,2)==l));
        P(i,l)=MFLR(i,l)/MF(i,l);
end
end
for i=1:k+1
for l=1:k+1
if P(i,l)>=0
            P(i,l)=P(i,l);
else
            P(i,:)=0;
end
end
end
disp('Matriks R yang terbentuk adalah');
disp(P)
%% Fuzzy Logical Relationship (FLRG)
for i =1:k+1    
   flrg{i} = flr(flr(:,1)==i,2);
end

disp('Fuzzy Logic Relationship Group (FLRG)');
for i =1:k+1
   flrgs{i} = unique(sort(flrg{i}));
   disp(['Current State A' num2str(i) '->']);
for j=1:length(flrgs{i})
        disp(['                  A' num2str(flrgs{i}(j))]);
end
end
%% Defuzzifikasi 
for i=1:k+1
    defuzz(i)=0;
if length(flrgs{i})>0
for m=2:k+1
            fdefuzz(1)=nilaitengah(1)*P(i,1);
            fdefuzz(m)=fdefuzz(m-1)+(nilaitengah(m)*P(i,m)); 
end
        defuzz(i)=fdefuzz(k+1);
else
       defuzz(i)=nilaitengah(i);
end
end
%% Nilai Penyesuaian Ramalan (Adjustment)
ll=[];
for i=1:k+1
    med(i,1)=(MU(i,2)-MU(i,1))/2;
end
for i=1:length(flr)
    selisih(i,1)=flr(i,2)-flr(i,1);
end
for i=1:length(flr)
if selisih(i)==0;
        adj(i,1)=0;
elseif selisih(i)>0
if selisih(i)==1
            adj(i,1)=med(flr(i,2));
else
            ll{i}(1)=0;
for j=2:abs(selisih(i))+1
%ll(j)=ll(j-1)+med(flr(i,1)+j-1);
            ll{i}(j)=med(flr(i,1)+j-1);
end
%adj(i,1)=ll(end);
        adj(i,1)=sum(ll{i});
end
elseif selisih(i)<0
if selisih(i)==-1
            adj(i,1)=-med(flr(i,2));
else
            ll{i}(1)=0;
for j=2:abs(selisih(i))+1
%ll(j)=ll(j-1)-med(flr(i,1)-j+1);
            ll{i}(j)=med(flr(i,1)-j+1);
end
        adj(i,1)=-sum(ll{i});
end
end
end
adjj=[0;adj;0];
    forecasting = (defuzz(fuzzifikasi));
    forecasting1 = zeros(length(forecasting)+1,1);
    forecasting1(1:end-1)=forecasting(1:end);
    forecasting1(end)=defuzz(fuzzifikasi(end));
    fuzzifikasi;
    fuzzifikasi1=zeros(length(fuzzifikasi)+1,1);
    fuzzifikasi1(1)=0;
    fuzzifikasi1(1:end-1)=fuzzifikasi(1:end);
    fuzzifikasi1(end)=fuzzifikasi(end);
    forecasting_akhir(1)=0;
for j=2:length(data)+1
% Menggunakan Nilai Penyesuaian   forecasting_akhir(j)=forecasting1(j)+P(fuzzifikasi1(j),fuzzifikasi1(j))*(data(j-1)-nilaitengah(fuzzifikasi1(j)))+adjj(j); 
end
%% Menampilkan Hasil Ramalan
disp('Hasil Forecasting')
for i=1:length(forecasting_akhir)-1
    disp([num2str(i) '.   ' num2str(data(i)) ' = ' num2str(forecasting_akhir(i))]);
end
disp(['Prediksi untuk data ke ' num2str(length(data)+1) ' = ' num2str(forecasting_akhir(end))]);
%% Menghitung Error dengan AFER
    er(1,i)=0;
for i=2:length(data)
    er(1,i)=abs(forecasting_akhir(i)-data(i));
    ab(1,i)=(er(1,i)/data(i))*100;
end
afer=sum(ab)/(length(data)-1);
disp(['Nilai MAPE diperoleh    ' num2str(afer)])
%% Sketsa Grafik Akhir
for i=1:length(data)-2
    x(i,1)=i;
    x(i+1,1)=x(i,1)+1;
end
plot(x,data(2:end),'-r',x,forecasting_akhir(2:end-1),'-b');
title('Grafik Harga Saham Pembukaan/Penutupan/Tertinggi PT. Waskita Karya Tbk Bulan Januari')
xlabel('Data periode ke-t');
ylabel({'Merah - Nilai Aktual pada periode ke-t';'Biru - Nilai Ramalan pada periode ke-t'});
%%  Penghitungan Plrnghtartition Coefficient (PC)
A=u.^2;
f=(sum(A(:)))/length(data);
disp(['Partition Coefficient :  ' num2str(f)]);

