# ����� �������
#   sold:  ItemID CreatedDate
#   publish:  ItemID ProductID price_real shipping_real add_date

# ��������� ������� ����� ����������
#   ������������ ���� ������ myBDUser = "admin";
#   ������ � ���� ������ myBDPassword = "password";
#   myHost = "RDS Host";
#   myDbname = "MyDB";
#	  route = "/var/www/html/img/";

# �������������� ���������
# ����� ���������
# ��� ����
# ���� ����
# �����

args <- commandArgs(trailingOnly = T); # �������� ��������� �� ��������� ������

{
  FormatDate = "%Y-%m-%d %H:%M";
  myBDUser = args[1];
  myBDPassword = args[2];
  myHost = args[3];
  myDbname = args[4];
  categoryID = ifelse(args[5]!="NA", args[5], "*");
  minPrice = ifelse(args[6]!="NA", args[6], "0");
  maxPrice = ifelse(args[7]!="NA", args[7], "99999");
  brand = ifelse(args[8]!="NA", args[8], "*");
  myRoute = "/home/victorynox/PhpstormProjects/TestR/public/img/";
  myCol = "red";
  mySize = c(960, 960);
  
}# ���������� ����������

getData <- function(name,
                    bdName = myDbname,
                    category = CategoryID,
                    myBrand = brand,
                    minP = minPrice,
                    maxP = maxPrice)
{
  if(name == "publish")
    return(paste("select publish.add_date, publish.ItemID, publish.ProductID, publish.price_real, publish.shipping_real ",
                 " from ", bdName, ".publish", ", ", bdName, ".products ",
                 "where publish.ProductID=products.ProductID and products.brand = '", myBrand, "' and products.ebaycategory_id = ", category, " and publish.price_real>", minP, " and publish.price_real<", maxP,";"  , sep = ""));
  
  if(name == "sold")
    return(paste("select sold.ItemID, sold.CreatedDate ",
                 "from ", bdName, ".sold ",
                 "where sold.ItemID in (select publish.ItemID from ",bdName, ".publish, ", bdName, ".products where publish.ProductID = products.ProductID and products.brand = '", myBrand,"' and products.ebaycategory_id = ", category," and publish.price_real>", minP, " and publish.price_real<", maxP, ");", sep = ""));
  
  
}


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

}# ���������� � ���� ������

checkData <- function(data)
{
  return(nrow(data)>10)
}

if(!checkData(data.sold) | !checkData(data.publish))
{
  print("ERROR");
}

if(checkData(data.sold) & checkData(data.publish))
{

{


change.publish <-function(publish=data.publish){
  
  return(publish);
}

change.sold <-function(sold=data.sold){
  
  return(sold);
}

}#��������� ��� ��������� �������� ������


{
data.publish = change.publish();
data.sold = change.sold();
}# ����� �������� ��������� �������� ������


plotOfDayWeek <- function(publish = data.publish, 
                          sold = data.sold,
                          colHist = myCol,
                          waySave = myRoute,
                          size = mySize){
  
  result = c("a","b","c","d");
  
  #������ ���� ����������� �������
  publish_date = strptime(publish$add_date, FormatDate);
  
  #������ ���� ����������� �������� �������
  publish_sold_date = strptime(merge(subset(sold, select = c(ItemID)), 
                                     subset(publish, select = c(ItemID, add_date)),
                                     by.x = "ItemID", 
                                     by.y = "ItemID")$add_date, 
                               FormatDate);
  
  #������ ���� ������� ������
  sold_date = strptime(sold$CreatedDate, FormatDate);
  
  {
    png(file=paste0(waySave, paste0(result[1], ".png")),width = size[1], height = size[2]);
    
    data.push_day_of_week_beg_hist = hist(as.numeric(format(publish_date, "%u")),
                                          breaks=seq(0,7,1),
                                          freq = FALSE,
                                          col = colHist,
                                          labels = TRUE,
                                          main = "����������� ���������� ����������� �� ��� ������",
                                          xlab = "���� ������");
    
    box();
    
    dev.off();
  }#����������� ����������� �� ��� ������
  
  {
  png(file=paste0(waySave, paste0(result[2], ".png")),width = size[1], height = size[2]);
  
  data.sold_day_of_week_beg_hist = hist(as.numeric(format(publish_sold_date, "%u")),
                                        breaks = seq(0,7,1),
                                        freq = FALSE,
                                        col = colHist,
                                        labels = TRUE,
                                        main = "����������� ���������� �������� �� ��� ������ �����������",
                                        xlab = "���� ������");
  
  
  box();
  
  dev.off();
  } #����������� �������� �� ��� ������ �����������
  
  {
  png(file=paste0(waySave, paste0(result[3], ".png")),width = size[1], height = size[2]);
  
  data.sold_day_of_week_end_hist = hist(as.numeric(format(sold_date, "%u")),
                                        breaks = seq(0,7,1),
                                        freq = FALSE,
                                        col = colHist,
                                        labels = TRUE,
                                        main = "����������� �������� �� ��� ������",
                                        xlab = "���� ������");
  
  box();
  
  dev.off();
  }#����������� �������� �� ��� ������
  
  #������ ����������� ������� ������ ������������ � ������� ���� ������
  data.sold_day_of_week_beg_relat = data.sold_day_of_week_beg_hist$counts/data.push_day_of_week_beg_hist$counts;
  
  {
    png(file=paste0(waySave, paste0(result[4], ".png")),width = size[1], height = size[2]);
    
    data.sold_day_of_week_beg_relat_plot = plot(seq(1,7,1),
                                                data.sold_day_of_week_beg_relat,
                                                type = "o",
                                                main = "������ ����������� ������� ������ ������������ � ������� ���� ������",
                                                xlab = "���� ������",
                                                ylab = "�����������");
    box();
    
    dev.off();
  }#������ ����������� ������� ������ ������������ � ������� ���� ������
  return(result)
}#����������� �� ���� ������

res <- plotOfDayWeek()
n <- length(res);

for(i in 1:n)
{
  print(res[i]);
}
}