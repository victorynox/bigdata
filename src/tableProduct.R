# ����� �������
#   sold:  ItemID
#   publish:  ItemID ProductID price_real shipping_real

# ��������� ������� ����� ����������
#   ������������ ���� ������ myBDUser = "admin";
#   ������ � ���� ������ myBDPassword = "password";
#   myHost = "RDS Host";
#   myDbname = "MyDB";
#	  route = "/var/www/html/img/";
#   myProb = 1.26
#   countView = 100

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
  myRoute = "/var/www/TestR/csv/";
  myProb = as.integer(args[5]);
  countView = as.integer(args[6]);
  categoryID = ifelse(args[7]!="NA", args[7], "*");
  minPrice = ifelse(args[8]!="NA", args[8], "0");
  maxPrice = ifelse(args[9]!="NA", args[9], "99999");
  brand = ifelse(args[10]!="NA", args[10], "*");
  
}# ���������� ����������

getData <- function(name,
                    bdName = myDbname,
                    category = CategoryID,
                    myBrand = brand,
                    minP = minPrice,
                    maxP = maxPrice)
{
  if(name=="publish")
  {
    return(paste())
  }
  
  if(name=="sold")
  {
    return(paste())
  }
  
}


{
library(RMySQL)
con <- dbConnect(MySQL(),
                 user = myBDUser,
                 password = myBDPassword,
                 host = myHost,
                 dbname=myDbname);

data.publish <- data.frame(dbGetQuery(conn = con, statement = paste("select ItemID, ProductID, price_real, shipping_real from ", myDbname, ".publish;",sep = "")));
data.sold <-data.frame(dbGetQuery(conn = con, statement = paste("select ItemID from ", myDbname, ".sold;", sep="")));

dbDisconnect(con);

}# ���������� � ���� ������


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


tableProduct <- function(publish = data.publish, 
                         sold = data.sold,
                         delta_prob = myProb){
  
  #������� ������ � ���������: ProductID, count_sold
  sold_product = data.frame(table(merge(subset(sold, select = c(ItemID)),
                                        subset(publish, select = c(ItemID, ProductID)),
                                        by.x = "ItemID",
                                        by.y = "ItemID")$ProductID));
  names(sold_product) = c("ProductID", "count_sold");
  
  
  #������� ������ � ���������: ProductID, count_push
  push_product = data.frame(table(publish$ProductID));
  names(push_product) = c("ProductID", "count_push");
  
  #������� ������ � ���������: ProductID, count_sold, count_push
  table_product = merge(sold_product,
                        push_product,
                        by.x = "ProductID",
                        by.y = "ProductID");
  
  {
    mean_price = data.frame(aggregate(publish$price_real+publish$shipping_real,
                                      by = list(ProductID = publish$ProductID),
                                      mean));
    names(mean_price) = c("ProductID", "price")
    
    table_product = merge(table_product,
                          mean_price,
                          by.x = "ProductID",
                          by.y = "ProductID");
  }#��������� ������� ���� ������
  
  
  
  #��������� ����������� �������(prob)
  table_product = transform(table_product, prob = pmin(1,count_sold/count_push));
  
  #��������� ������� ������� �� �����(prof_mounth)
  table_product = transform(table_product, prof_mounth = (prob*price/10-0.05)*count_push/7);
  
  #��������� ����������� ��� ����� ������� �����������(new_prob)
  table_product = transform(table_product, new_prob = pmin(1, count_sold*delta_prob/(count_push+(1-delta_prob)*count_sold)));
  
  #��������� ����� ������� ������� �� �����(new_prof_mounth)
  table_product = transform(table_product, new_prof_mounth = (new_prob*price/10-0.15)*(count_push+(1-delta_prob)*count_sold)/7);
  
  #��������� ��������� ������� ������� �� �����(delta_prof_mounth)
  table_product = transform(table_product, delta_prof_mounth = new_prof_mounth - prof_mounth);
  
  #��������� �� �������� ������� �������
  table_product = table_product[order(-table_product$delta_prof_mounth),];
  
  return(table_product);
}#������� ������ �� ��������� �������



saveTable <- function(table,
                      waySave = myRoute,
                      name,
                      sepSave = "|"){
  
  
  write.table(head(data.frame(table[1],round(table[-1], digits = 3)),countView),
              file = paste0(waySave, name, ".csv"),
              sep = sepSave,
              row.names = FALSE);
  
}#������� ��� ���������� �������

result = "a";

saveTable(table = tableProduct(), name = result);

type = "Table";
type

result;
