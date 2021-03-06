# ����� �������
#   sold:  ItemID
#   publish:  ItemID ProductID price_real shipping_real

# ��������� ������� ����� ����������
#   ������������ ���� ������ myBDUser = "admin";
#   ������ � ���� ������ myBDPassword = "password";
#   myHost = "RDS Host";
#   myDbname = "MyDB";
#	  route = "/var/www/html/img/";


# �������������� ���������
# ����� ���������
# �����

args <- commandArgs(trailingOnly = T);# ��������� ��������� �� ��������� ������
library(RMySQL);
{
  FormatDate = "%Y-%m-%d %H:%M";
  myBDUser = args[1];
  myBDPassword = args[2];
  myHost = args[3];
  myDbname = args[4];
  myRoute = "/home/victorynox/PhpstormProjects/TestR/public/img/";
  myProf =as.integer(args[5]);
  CategoryID = ifelse(args[6]!="NA", args[6], "*")
  brand = ifelse(args[7]!="NA", args[7], "*");
  myCol = "red";
  mySize = c(960, 960);
  
}# ��������� �������

getData <- function(name,
                    bdName = myDbname,
                    category = CategoryID,
                    myBrand = brand)
{
  if(name == "publish")
    return(paste("select publish.ItemID, publish.ProductID, publish.price_real, publish.shipping_real ",
                 "from ", bdName, ".publish", ", ", bdName, ".products ",
                 "where publish.ProductID=products.ProductID and products.brand = '", myBrand, "' and products.ebaycategory_id = ", category, ";"  , sep = ""));

  if(name == "sold")
    return(paste("select sold.ItemID ",
                 "from ", bdName, ".sold ",
                 "where sold.ItemID in (select publish.ItemID from ",bdName, ".publish, ", bdName, ".products where publish.ProductID = products.ProductID and products.brand = '", myBrand,"' and products.ebaycategory_id = ", category, ");", sep = ""));
  

  }# ���������� �������� ��� ������ � ��������������� ����������

{
  library(RMySQL)
  con <- dbConnect(MySQL(),
                   user = myBDUser,
                   password = myBDPassword,
                   host = myHost,
                   dbname=myDbname);
  
  data.publish <- data.frame(dbGetQuery(conn = con, statement = getData("publish")));
  data.sold <-data.frame(dbGetQuery(conn = con, statement = getData("sold")));
  
  q<-dbDisconnect(con);
  
}#���������� ������ �� ���� ������

checkData <- function(data)
{
  return(nrow(data)>10)
}# ������� �������� ������� ������

if(!checkData(data.sold) | !checkData(data.publish))
{
  print("ERROR");
}#���� ������ �� ���������� ����� ������� ERROR

if(checkData(data.sold) & checkData(data.publish))
{
  
{


change.publish <-function(publish=data.publish){
  
  return(publish);
}

change.sold <-function(sold=data.sold){
  
  return(sold);
}

}#��������� ��������� ������


{
  data.publish = change.publish();
  data.sold = change.sold();
}# ����� �������� ��������� ������

#���������� ������ Breaks ��� ����������
maxPrice = log10(max(data.publish$price_real+data.publish$shipping_real,na.rm = T))+0.2;
myBreaks = seq(0, maxPrice, by = 0.1);



plotPrice <- function(publish = data.publish, 
                      sold = data.sold,
                      colHist = myCol,
                      waySave = myRoute,
                      prof = myProf,
                      size = mySize){

  result = c("a","b","c","d");
  {
    png(file=paste0(waySave, paste0(result[1], ".png")),width = size[1], height = size[2]);
    
    
    data.push_price_hist = hist(log10(publish$price_real+publish$shipping_real),
                                freq = FALSE,
                                breaks = myBreaks, 
                                col = colHist,
                                labels = TRUE,
                                main = "����������� ���������� ����������� ������ ����������� ����",
                                xlab = "Log10(Price)");
    lines(density(log10(publish$price_real+publish$shipping_real)),
          col="blue",
          lwd=2);
    
    box();
    
    dev.off();
  }#���������� ����������� �� ���� ����������� �������
  
  #������� � ����� �������� �������
  data.sold_and_price = merge(subset(sold, select = c(ItemID)), 
                              subset(publish, select = c(ItemID, price_real, shipping_real)),
                              by.x = "ItemID", 
                              by.y = "ItemID");
  
  {
    png(file=paste0(waySave, paste0(result[2], ".png")),width = size[1], height = size[2]);
    
    data.sold_price_hist = hist(log10(data.sold_and_price$price_real+data.sold_and_price$shipping_real),
                                freq = FALSE,
                                breaks = myBreaks,
                                col = colHist,
                                labels = TRUE,
                                main = "����������� ���������� ������ ������������ ���� ������",
                                xlab = "Log10(Price)");
    lines(density(log10(data.sold_and_price$price_real+data.sold_and_price$shipping_real)),
          col="blue",
          lwd=2);
    box();
    
    dev.off();
  }#���������� ����������� ���������� ������ ������������ ���� ������
  
  #������ ���������� ������� ������ � ������� ������� ����������
  data.price_relat = data.sold_price_hist$counts/data.push_price_hist$counts[1:length(data.sold_price_hist$counts)];
  
  {
    png(file=paste0(waySave, paste0(result[3], ".png")),width = size[1], height = size[2]);
    
    data.price_relat_plot = plot(myBreaks[1:length(data.price_relat)],
                                 data.price_relat,
                                 type = "o", 
                                 main = "������ ����������� ������� ������ � ������� �����",
                                 xlab = "log10(Price)",
                                 ylab = "����������� �������");
    box();
    
    dev.off();
  }#���������� ������� ������������ ������� ������ � ������� �����
  
  #������ ������� �� ������� ������ � ������� ����� ��� myProf ���������� ������
  data.prof = (10^myBreaks[1:length(data.price_relat)])*myProf/100;
  
  
  {
    png(file=paste0(waySave, paste0(result[4], ".png")),width = size[1], height = size[2]);
    
    data.price_prof_plot = plot(myBreaks[1:length(data.price_relat)],
                                data.price_relat*data.prof,
                                type = "o",
                                main = "������ ������� ������������ ���� ������",
                                xlab = "log10(Price)",
                                ylab = "Profit");
    box();
    
    dev.off();
  }#���������� ������� ������� ������������ ���� ������
  
  return(result);
}#������� ���������� ����������

res <-plotPrice();
n <- length(res);

for(i in 1:n)
{
  print(res[i]);
}
}#���� ������ ���������� ����� ����� �����������
