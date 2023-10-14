#include "fileOperations.h"
#include <QDebug>
#include <QFile>

FileOperations::FileOperations(QObject *parent):
QObject(parent)
{
}

void FileOperations::printMessage(QString txt)
{
	qDebug() << "Message from QML: " << txt;
}

void FileOperations::saveDataToFile(QString glyphID, QString dataToSave)
{
	const QString qPath("./data/" + glyphID + ".json");
	QFile qFile(qPath);
	if (qFile.open(QIODevice::WriteOnly)) 
	{
		QTextStream out(&qFile); out << dataToSave;
		qFile.close();
	}
}
void FileOperations::saveSVG(QString dataToSave)
{
	const QString qPath("./data/savedGlyph.svg");
	QFile qFile(qPath);
	if (qFile.open(QIODevice::WriteOnly)) 
	{
		QTextStream out(&qFile); out << dataToSave;
		qFile.close();
	}
}
QString FileOperations::loadLetter(QString glyphID)
{
	const QString qPath("./data/" + glyphID + ".json");
	QFile qFile(qPath);
	if (!qFile.open(QIODevice::ReadOnly | QIODevice::Text))
	{
    	const QString defaultValue("null");
    	return defaultValue;
	}
	else
	{
		QTextStream in(&qFile);
		QString fileContents = in.readAll();
		qFile.close();
		return fileContents;
	}
}
QString FileOperations::loadDataFromFile()
{
	const QString qPath("fontData.json");
	QFile qFile(qPath);
	if (!qFile.open(QIODevice::ReadOnly | QIODevice::Text))
	{
    	const QString defaultValue("{}");
    	return defaultValue;
	}
	else
	{
		QTextStream in(&qFile);
		QString fileContents = in.readAll();
		qFile.close();
		return fileContents;
	}
}

//virtual FileOperations::~FileOperations() {};
//void FileOperations::~FileOperations() {};