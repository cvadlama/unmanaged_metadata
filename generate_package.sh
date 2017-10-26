echo "Running step 1 generateManifestPart1 ......"
ant generateManifestPart1

grep ChildObjects deleteme/describeMetadata.txt | sed -e 's/\*//g' | grep "ChildObjects: .[a-zA-Z0-9]*" | cut -d":" -f2- | sed -e $'s/,/\\\n/g' | sed -e 's/ //g' | grep -v -f exclusions > deleteme/tmp.chum

grep "InFolder: false" -B 4 deleteme/describeMetadata.txt | grep "XMLName" | cut -f2 -d":" | sed -e 's/ //g' | grep -v -f exclusions >>  deleteme/tmp.chum

sort -u deleteme/tmp.chum -o deleteme/tmp.chum

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"  > package.xml

echo "<Package xmlns=\"http://soap.sforce.com/2006/04/metadata\">" >> package.xml

for i in `cat deleteme/tmp.chum`; do echo "<types><members>*</members><name>REPLACEME</name></types>" | sed -e "s/REPLACEME/$i/g"; done >> package.xml

# Check if there are unmanaged documents

grep "Manageable State: unmanaged" -B 3 deleteme/document.log | grep "FileName:" | cut -f2 -d"/" | sed -e 's/FileName: unfiled/unfiled/g' > deleteme/unmanaged_documents.log
rm deleteme/document.log


# Check if there are unmanaged reports

grep "Manageable State: unmanaged" -B 3 deleteme/report.log | grep "FileName:" | cut -f2 -d"/" | sed -e 's/FileName: unfiled/unfiled/g' > deleteme/unmanaged_reports.log
rm deleteme/report.log


# Check if there are unmanaged dashboards

grep "Manageable State: unmanaged" -B 3 deleteme/dashboard.log | grep "FileName:" | cut -f2 -d"/" | sed -e 's/FileName: unfiled/unfiled/g' > deleteme/unmanaged_dashboards.log
rm deleteme/dashboard.log


# Check if there are unmanaged email templates

grep "Manageable State: unmanaged" -B 3 deleteme/email.log | grep "FileName:" | cut -f2 -d"/" | sed -e 's/FileName: unfiled/unfiled/g' > deleteme/unmanaged_emails.log
rm deleteme/email.log

# check for reports,dashboards,documents and email templates

echo "Running extraction for email templates ......"

ant generateEmailTemplateData

echo "Running extraction for dashboards ......"

ant generateDashboardData

echo "Running extraction for documents ......"

ant generateDocumentData

echo "Running extraction for reports ......"

ant generateReportData

#generate the members for dashboard
if ls deleteme/Dashboard_* 1> /dev/null 2>&1; then
    echo "<types>" >>package.xml
    echo "<members>*</members>" >>package.xml
    cat deleteme/Dashboard_* | grep "FileName:" | cut -f2 -d":" | cut -f1 -d"." | sed -e 's/ dashboards\///g' | sed -e 's/^/<members>/g' | sed -e 's/$/<\/members>/g' >> package.xml

    echo "<name>Dashboard</name></types>" >> package.xml

fi

#generate the members for report
if ls deleteme/Report_* 1> /dev/null 2>&1; then
    echo "<types>" >>package.xml
    echo "<members>*</members>" >>package.xml
    cat deleteme/Report_* | grep "FileName:" | cut -f2 -d":" | cut -f1 -d"." | sed -e 's/ reports\///g' | sed -e 's/^/<members>/g' | sed -e 's/$/<\/members>/g' >> package.xml

    echo "<name>Report</name></types>" >> package.xml

fi

#generate the members for document
if ls deleteme/Document_* 1> /dev/null 2>&1; then
    echo "<types>" >>package.xml
    echo "<members>*</members>" >>package.xml
    cat deleteme/Document_* | grep "FileName:" | cut -f2 -d":" | sed -e 's/ //g' | sed -e 's/^/<members>/g' | sed -e 's/$/<\/members>/g' >> package.xml

    echo "<name>Document</name></types>" >> package.xml

fi

#generate the members for email templates
if ls deleteme/EmailTemplate_* 1> /dev/null 2>&1; then
    echo "<types>" >>package.xml
    echo "<members>*</members>" >>package.xml
    cat deleteme/EmailTemplate_* | grep "FileName:" | cut -f2 -d":" | cut -f1 -d"." |sed -e 's/ email\///g' | sed -e 's/^/<members>/g' | sed -e 's/$/<\/members>/g' >> package.xml

    echo "<name>EmailTemplate</name></types>" >> package.xml

fi

# Need to automate get the platform version. But for another day.

echo "<version>40.0</version>" >>package.xml

echo "</Package>" >>package.xml

# formatting the xml is an important step in the process so we can get the exact line number for the match.

xmllint --format package.xml --output package.xml

# addming standard object inclusions

line=$(grep -n '<name>CustomObject</name>' package.xml | cut -d ":" -f 1)

{ head -n $(($line-1)) package.xml; for i in `cat inclusions`; do echo "<members>$i</members>"; done; tail -n +$line package.xml; } > deleteme/newpackage.xml

cp deleteme/newpackage.xml package.xml

# the following formatting is more cosmentic if you want to see what
# it looks like in an editor.

xmllint --format package.xml --output package.xml

rm -rf deleteme

#ant
