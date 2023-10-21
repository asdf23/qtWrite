#include "fileOperations.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QDir>

FileOperations::FileOperations(QObject *parent): QObject(parent)
{
}

void FileOperations::printMessage(QString txt)
{
	qDebug() << "Message from QML: " << txt;
}

void FileOperations::saveDataToFile(QString glyphID, QString dataToSave)
{
	QDir dir = QDir::currentPath();
	if(! dir.cd("../data"))
	{
		return;
	}
	else
	{
		QFile qFile(dir.absoluteFilePath(glyphID + ".json"));
		if(qFile.open(QIODevice::WriteOnly)) 
		{
			QTextStream out(&qFile); out << dataToSave;
			qFile.close();
		}
	}
}
void FileOperations::saveGlyphs(QString fileName, QString dataToSave)
{
	QDir dir = QDir::currentPath();
	if(! dir.cd("../data"))
	{
		return;
	}
	else
	{
		QFile qFile(dir.absoluteFilePath(fileName));
		if(qFile.open(QIODevice::WriteOnly)) 
		{
			QTextStream out(&qFile); out << dataToSave;
			qFile.close();
		}
	}
}
void FileOperations::saveSVG(QString dataToSave)
{
	QDir dir = QDir::currentPath();
	if(! dir.cd("../data"))
	{
		return;
	}
	else
	{
		QFile qFile(dir.absoluteFilePath("savedGlyph.svg"));
		if(qFile.open(QIODevice::WriteOnly)) 
		{
			QTextStream out(&qFile); out << dataToSave;
			qFile.close();
		}
	}
}
QString FileOperations::loadLetter(QString glyphID)
{
	//working 6.5 const QString qPath("/home/user1/dev/pub/qtWrite/data/" + glyphID + ".json");
		//failed 6.5 const QString qPath("qrc:///qml/data/" + glyphID + ".json");
		//failed 6.5 const QString qPath("data/" + glyphID + ".json");
		//failed 6.5 const QString qPath("qrc://data/" + glyphID + ".json");
		QDir dir = QDir::currentPath();
		if(! dir.cd("../data") ) //up from build 
		{
			//return "failed dir DNE " + dir.absolutePath();
			return "null";
		} 
		else 
		{
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
}
//virtual FileOperations::~FileOperations() {};
//void FileOperations::~FileOperations() {};
