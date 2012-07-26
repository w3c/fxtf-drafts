#!/usr/bin/perl -w

# An exceptionally hacky script that performs the same kind of automatic
# linking of <a> elements that is done for the SVG specifications, based
# on the definitions*.xml files in this directory.
#
# (Warning: regular expression based munging of XML ahead.)

use strict;

sub loaddefs {
  readdefs('definitions-SVG11.xml', 'http://www.w3.org/TR/2011/REC-SVG11-20110816/');
  readdefs('definitions-filters.xml', '');
}

sub readfile {
  my $fh;
  my $fn = shift;
  local $/;
  open $fh, $fn;
  my $s = join('', <$fh>);
  return $s;
}

sub dec {
  my $s = shift;
  $s =~ s/\&lt;/</g;
  $s =~ s/\&gt;/>/g;
  $s =~ s/\&apos;/>/g;
  $s =~ s/\&amp;/\&/g;
  return $s;
}

my $htmlfn = $ARGV[0] or die;

my $html = readfile($htmlfn);

my $dfn;
my %dfns;
while ($html =~ /<dfn([^>]*)>(.*?)<\/dfn>/gs) {
  my $attrs = $1;
  my $name = $2;
  if ($attrs =~ /title=(?:"(.*?)"|'(.*?)')/s) {
    $name = $1 || $2;
  }
  $dfns{$name} = 1;
}

my %elements;
my %elementAttributes;
my %elementCategoryAttributes;
my %properties;

sub readdefs {
  my $fn = shift;
  my $base = shift;

  my $defs = readfile($fn);

  while ($defs =~ s/<attributecategory\s(.*?)(?:\/>|>(.*?)<\/attributecategory>)//s) {
    my $attrs = $1;
    my $children = $2;

    $attrs =~ /name=['"](.*?)['"]/ or die;
    my $name = $1;

    $elementCategoryAttributes{$name} = { };

    if (defined $children) {
      while ($children =~ /<attribute(.*?)\/>/gs) {
        my $children2 = $1;

        $children2 =~ /name=['"](.*?)['"]/ or die;
        my $attrName = $1;

        $children2 =~ /href=['"](.*?)['"]/ or die;
        my $attrHref = $1;

        $elementCategoryAttributes{$name}{$attrName} = "$base$attrHref";
      }
    }
  }

  while ($defs =~ s/<element\s(.*?)(?:\/>|>(.*?)<\/element>)//s) {
    my $attrs = $1;
    my $children = $2;

    $attrs =~ /name=['"](.*?)['"]/ or die;
    my $name = $1;

    $attrs =~ /href=['"](.*?)['"]/ or die;
    my $href = $1;

    $elements{$name} = "$base$href";

    $elementAttributes{$name} = { };

    if ($attrs =~ /attributecategories=['"](.*?)['"]/) {
      my @cats = split(/,\s*/, $1);
      for my $cat (@cats) {
        for my $catattr (keys %{$elementCategoryAttributes{$cat}}) {
          $elementAttributes{$name}{$catattr} = $elementCategoryAttributes{$cat}{$catattr};
        }
      }
    }

    if (defined $children) {
      while ($children =~ /<attribute(.*?)\/>/gs) {
        my $children2 = $1;

        $children2 =~ /name=['"](.*?)['"]/ or die;
        my $attrName = $1;

        $children2 =~ /href=['"](.*?)['"]/ or die;
        my $attrHref = $1;

        $elementAttributes{$name}{$attrName} = "$base$attrHref";
      }
    }
  }

  while ($defs =~ s/<attribute\s+name=['"](.*?)['"]\s+elements=['"](.*?)['"]\s+href=['"](.*?)['"]\s*\/>//s) {
    my $attrName = $1;
    my $attrHref = $3;
    my @elements = split(/,\s*/, $2);
    for my $element (@elements) {
      $elementAttributes{$element}{$attrName} = $attrHref;
    }
  }

  while ($defs =~ s/<property\s+name=['"](.*?)['"]\s+href=['"](.*?)['"]\s*\/>//s) {
    $properties{$1} = "$base$2";
  }
}

sub link {
  my $text = shift;
  if ($text =~ /^'([^ \/]*)'$/) {
    my $name = $1;
    if (defined $elements{$name}) {
      return "<a class='element-name' href='$elements{$name}'>'$name'</a>";
    } elsif (defined $properties{$name}) {
      return "<a class='property' href='$properties{$name}'>'$name'</a>";
    }
    print STDERR "unknown element or property '$1'\n";
    return "<span class='xxx'>$text</span>";
  } elsif ($text =~ /^'([^ \/]*) element'$/) {
    my $name = $1;
    unless (defined $elements{$name}) {
      print STDERR "unknown element '$1'\n";
      return "<span class='xxx'>$text</span>";
    }
    return "<a class='element-name' href='$elements{$name}'>'$name'</a>";
  } elsif ($text =~ /^'([^ \/]*) property'$/) {
    my $name = $1;
    unless (defined $properties{$name}) {
      print STDERR "unknown element '$1'\n";
      return "<span class='xxx'>$text</span>";
    }
    return "<a class='property' href='$properties{$name}'>'$name'</a>";
  } elsif ($text =~ /^'([^ ]*)\/([^ ]*)'$/) {
    my $eltname = $1;
    my $attrname = $2;
    unless (defined $elements{$eltname} && defined $elementAttributes{$eltname}{$attrname}) {
      print STDERR "unknown attribute '$attrname' on element '$eltname'\n";
      return "<span class='xxx'>$text</span>";
    }
    return "<a class='attr-name' href='$elementAttributes{$eltname}{$attrname}'>'$eltname'</a>";
  }
  return "<span class='xxx'>$text</span>";
}

loaddefs();

$html =~ s{<a>(.*?)<\/a>}{&link($1)}egs;

print $html;
