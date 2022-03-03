	%% Algoritma Fuzzy Time Series dengan Algoritma Fuzzy C-Means Clustering
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
[center,u,objFcn]=fcm(data,k); center; u; objFcn;
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
%% Mendefinisikan Himpunan Fuzzy
hf=zeros(k,k);
hf(1,1)=1; hf(1,2)=0.5; hf(k+1,k+1)=1; hf(k+1,k)=0.5;
for i=2:k
    hf(i,i-1)=0.5;
    hf(i,i+1)=0.5;
    hf(i,i)=1;
end
%% Fuzzifikasi
for i=1:length(data)
if data(i)<nilaitengah(1)
        fuzz(i,1)=1;
elseif data(i)>nilaitengah(k+1)
        fuzz(i,k+1)=1;
else
for s=2:k+1
if data(i)>nilaitengah(s-1) && data(i)<nilaitengah(s)
                fuzz(i,s-1)=(data(i)-nilaitengah(s-1))/(nilaitengah(s)-nilaitengah(s-1));
                fuzz(i,s)=(nilaitengah(s)-data(i))/(nilaitengah(s)-nilaitengah(s-1));
else
end
end
end
end

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
%% Fuzzy Logical Relationship (FLRG)
for i =1:k+1    
   flrg{i} = flr(flr(:,1)==i,2);
end
disp('Fuzzy Logic Relationship Group (FLRG)');
for i =1:k+1
   flrgs{i} = unique(sort(flrg{i}))';
   disp(['Current State A' num2str(i) '->']);
for j=1:length(flrgs{i})
        disp(['                  A' num2str(flrgs{i}(j))]);
end
end
%% Membentuk Matriks R
A=[];
for i=1:length(flrgs)
for j=1:length(flrgs{i})
        A{i}(j,1)=i;
        A{i}(j,2)=flrgs{i}(j);
end
end
AA=[];
AA{1}=A{1};
for i=1:length(A)-1
    AA{i+1}=[AA{i}; A{i+1}];
end
B=AA{length(A)}; C=[];
for i=1:length(B)
    C{i}=hf(B(i,1),:)'*(hf(B(i,2),:));
end
D=[];
for j=1:k+1
for m=1:k+1
        D{1}=0;
for i=1:length(C)
            D{i+1}=[D{i} C{i}(j,m)];
end
        R(j,m)=max(D{length(C)+1});
end
end
%% Menghitung Nilai Ramalan
hr=[];
for i=1:length(data)
for m=1:k+1
        h{1}=min(fuzz(i,1),R(1,m));
for j=1:k
            h{j+1}=[h{j} min(fuzz(i,j+1),R(j+1,m))];
end
        hr(i,m)=max(h{k+1});
end
end
%% Defuzzifikasi
for i=1:length(data)
    v=find(hr(i,:)==max(hr(i,:)));
if length(v)==1
        fr(i,1)=nilaitengah(v);
else
        vv(1)=nilaitengah(v(1));
for k=1:length(v)-1
            vv(k+1)=vv(k)+nilaitengah(v(k+1));
end
        fr(i,1)=vv(length(v))/length(v);
end
end
%% Menampilkan Hasil Ramalan
frr=[0;fr];
forecasting=zeros(length(data));
forecasting=frr(1:end-1);
disp('Hasil Ramalan diperoleh:');
for i=1:length(data)
    disp([num2str(i) '. ' num2str(data(i)) ' = ' num2str(forecasting(i))]);
end
%% Hitung AFER (Keakuratan Ramalan)
disp(['Nilai Ramalan pada periode ke-' num2str(length(data)+1) ' adalah ' num2str(frr(end))]);
    er(1,i)=0;
for i=2:length(data)
    er(1,i)=abs(forecasting(i)-data(i));
    ab(1,i)=(er(1,i)/data(i));
end
afer=sum(ab)*100/(length(data)-1);
disp(['Nilai AFER diperoleh    ' num2str(afer)])
%% Sketsa Grafik Akhir
for i=1:length(data)-2
    x(i,1)=i;
    x(i+1,1)=x(i,1)+1;
end
plot(x,data(2:end),'-r',x,forecasting(2:end),'-b');
title('Grafik Harga Saham Tertinggi PT. Waskita Karya Tbk Bulan Januari')
xlabel('Data periode ke-t');
ylabel({'Merah - Nilai Aktual pada periode ke-t';'Biru - Nilai Ramalan pada periode ke-t'});
%%  Penghitungan Plrnghtartition Coefficient (PC)
A=u.^2;
f=(sum(A(:)))/length(data);
disp(['Partition Coefficient :  ' num2str(f)]);