#include "fileOperations.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QQmlEngine>

FileOperations::FileOperations(QObject *parent) : QObject(parent)
{
}

QDir FileOperations::getDataDirectory()
{
	//working 6.5 const QString qPath("/home/user1/dev/pub/qtWrite/data/" + glyphID + ".json");
	//failed 6.5 const QString qPath("qrc:///qml/data/" + glyphID + ".json");
	//failed 6.5 const QString qPath("data/" + glyphID + ".json");
	//failed 6.5 const QString qPath("qrc://data/" + glyphID + ".json");
	QDir dir = QDir::current();
	if(dir.dirName() == "build")
	{
		if(!dir.cd("../data"))
		{
			qmlEngine(this)->throwError(tr("Bad path to ./build/../data"));
		}
	}
	else
	{
		if(!dir.cd("data"))
		{
			qmlEngine(this)->throwError(tr("Bad path to ./data"));
		}
	}
	return dir;
}

void FileOperations::printMessage(QString txt)
{
	qDebug() << "Message from QML: " << txt;
}

void FileOperations::saveDataToFile(QString glyphID, QString dataToSave)
{
	QDir dir = getDataDirectory();
	QFile qFile(dir.absoluteFilePath(glyphID + ".json"));
	if(qFile.open(QIODevice::WriteOnly)) 
	{
		QTextStream out(&qFile); out << dataToSave;
		qFile.close();
	}
}
void FileOperations::saveGlyphs(QString fileName, QString dataToSave)
{
	QDir dir = getDataDirectory();
	QFile qFile(dir.absoluteFilePath(fileName));
	if(qFile.open(QIODevice::WriteOnly)) 
	{
		QTextStream out(&qFile); out << dataToSave;
		qFile.close();
	}
}
void FileOperations::saveSVG(QString dataToSave)
{
	QDir dir = getDataDirectory();
	QFile qFile(dir.absoluteFilePath("savedGlyph.svg"));
	if(qFile.open(QIODevice::WriteOnly)) 
	{
		QTextStream out(&qFile); out << dataToSave;
		qFile.close();
	}
}
QString FileOperations::loadLetter(QString glyphID)
{
	QDir dir = getDataDirectory();	
	QFile qFile(dir.absoluteFilePath(glyphID + ".json"));
	if(qFile.exists()) 
	{
		if (!qFile.open(QIODevice::ReadOnly | QIODevice::Text))
		{
			return "{}";
		}
		else
		{
			QTextStream in(&qFile);
			QString fileContents = in.readAll();
			qFile.close();
			return fileContents;
		}
	}
	else 
	{
	  return "null";
	}
}
//virtual FileOperations::~FileOperations() {};
//void FileOperations::~FileOperations() {};
